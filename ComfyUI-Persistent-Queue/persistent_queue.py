import asyncio
import json
import logging
import os
import sqlite3

import folder_paths
from aiohttp import web
from server import PromptServer

logger = logging.getLogger("ComfyUI-Persistent-Queue")


class PersistentQueueManager:
    def __init__(self):
        self.data_dir = os.getenv(
            "COMFYUI_PERSISTENT_QUEUE_PATH",
            os.path.join(
                folder_paths.base_path, "custom_nodes_data", "comfyui-persistent-queue"
            ),
        )
        os.makedirs(self.data_dir, exist_ok=True)
        self.db_path = os.path.join(self.data_dir, "queue.sqlite3")
        self.config_path = os.path.join(self.data_dir, "config.json")
        self.last_seen_active_ids = set()
        self.last_seen_history_ids = set()
        self.needs_sync = False
        self.sync_task = None
        self.db_lock = asyncio.Lock()
        self._init_db()

    def _init_db(self):
        with sqlite3.connect(self.db_path) as conn:
            conn.execute(
                """
                CREATE TABLE IF NOT EXISTS prompts (
                    prompt_id TEXT PRIMARY KEY,
                    prompt_data TEXT,
                    status TEXT,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
                """
            )
            conn.commit()

    def get_config(self):
        if os.path.exists(self.config_path):
            try:
                with open(self.config_path, "r") as f:
                    return json.load(f)
            except Exception as e:
                logger.error(f"Failed to read config: {e}")
        return {"auto_load": False}

    def set_config(self, auto_load):
        config = self.get_config()
        config["auto_load"] = auto_load
        with open(self.config_path, "w") as f:
            json.dump(config, f)

    def _get_db(self):
        return sqlite3.connect(self.db_path)

    def setup(self):
        # Override queue_updated
        self.original_queue_updated = PromptServer.instance.queue_updated

        def new_queue_updated(*args, **kwargs):
            logger.info("ComfyUI queue_updated triggered!")
            self.original_queue_updated(*args, **kwargs)
            self.trigger_sync()

        PromptServer.instance.queue_updated = new_queue_updated

        # Setup API routes
        self._setup_routes()

        # Start background sync task
        asyncio.create_task(self._sync_loop())

        # Handle startup logic
        asyncio.create_task(self._handle_startup())

    async def _handle_startup(self):
        async with self.db_lock:
            with self._get_db() as conn:
                # Any prompts that were 'queued' or 'running' during the last crash
                # should now be marked as 'saved_from_crash'
                conn.execute(
                    "UPDATE prompts SET status = 'saved_from_crash' WHERE status IN ('queued', 'running')"
                )
                conn.commit()

                config = self.get_config()
                if config.get("auto_load", False):
                    cursor = conn.execute(
                        "SELECT prompt_id, prompt_data FROM prompts WHERE status = 'saved_from_crash'"
                    )
                    rows = cursor.fetchall()
                    
                    server = PromptServer.instance
                    for row in rows:
                        prompt_id = row[0]
                        data = json.loads(row[1])
                        # The tuple: (number, prompt_id, prompt, extra_data, outputs_to_execute, sensitive)
                        number = server.number
                        server.number += 1
                        server.prompt_queue.put((
                            number,
                            prompt_id,
                            data.get("prompt"),
                            data.get("extra_data"),
                            data.get("outputs_to_execute", []),
                            data.get("sensitive", []) # sensitive data is usually filtered out, but we might have saved it.
                        ))
                    
                    # They are now queued in ComfyUI, so update our DB
                    conn.execute("UPDATE prompts SET status = 'queued' WHERE status = 'saved_from_crash'")
                    conn.commit()

    def trigger_sync(self):
        self.needs_sync = True

    async def _sync_loop(self):
        while True:
            try:
                if self.needs_sync:
                    self.needs_sync = False
                    await self._perform_sync()
            except Exception as e:
                logger.error(f"Error in sync_loop: {e}")
            await asyncio.sleep(0.5)  # Debounce

    async def _perform_sync(self):
        queue = PromptServer.instance.prompt_queue
        
        # 1. Get atomic snapshot
        with queue.mutex:
            running, queued = queue.get_current_queue_volatile()
            history = queue.get_history()

        current_active_ids = set()
        active_prompts_data = {}

        # Parse running and queued
        for item in running + queued:
            # item = (number, prompt_id, prompt, extra_data, outputs_to_execute, sensitive)
            if len(item) < 6:
                 continue # Malformed
            prompt_id = item[1]
            current_active_ids.add(prompt_id)
            active_prompts_data[prompt_id] = {
                "prompt": item[2],
                "extra_data": item[3],
                "outputs_to_execute": item[4],
                "sensitive": item[5] if len(item) > 5 else []
            }
        
        history_ids = set(history.keys())

        async with self.db_lock:
            with self._get_db() as conn:
                # Additions (New tasks)
                added_ids = current_active_ids - self.last_seen_active_ids
                for pid in added_ids:
                    data = active_prompts_data[pid]
                    status = "running" if pid in [x[1] for x in running] else "queued"
                    conn.execute(
                        """
                        INSERT INTO prompts (prompt_id, prompt_data, status, updated_at)
                        VALUES (?, ?, ?, CURRENT_TIMESTAMP)
                        ON CONFLICT(prompt_id) DO UPDATE SET
                            prompt_data=excluded.prompt_data,
                            status=excluded.status,
                            updated_at=CURRENT_TIMESTAMP
                        """,
                        (pid, json.dumps(data), status)
                    )

                # Updates (e.g. queued -> running)
                # We can just update all current active ids to their correct state
                for pid in current_active_ids:
                    status = "running" if pid in [x[1] for x in running] else "queued"
                    conn.execute(
                        "UPDATE prompts SET status = ?, updated_at = CURRENT_TIMESTAMP WHERE prompt_id = ?",
                        (status, pid)
                    )

                # Deletions (Finished or Deleted)
                removed_ids = self.last_seen_active_ids - current_active_ids
                for pid in removed_ids:
                    if pid in history_ids:
                        # Finished successfully
                        conn.execute("UPDATE prompts SET status = 'completed', updated_at = CURRENT_TIMESTAMP WHERE prompt_id = ?", (pid,))
                    else:
                        # Cancelled/Deleted by user
                        # Delete from our history so it doesn't pollute the DB
                        conn.execute("DELETE FROM prompts WHERE prompt_id = ?", (pid,))

                # Catch prompts that executed so fast they bypassed our active observation
                logger.info(f"Checking history. Found {len(history)} items. last_seen_history_ids has {len(self.last_seen_history_ids)} items.")
                for pid, hist_data in history.items():
                    if pid not in self.last_seen_history_ids:
                        prompt_tuple = hist_data.get('prompt', [])
                        logger.info(f"Processing history item {pid}, prompt_tuple length: {len(prompt_tuple) if prompt_tuple else 'None'}")
                        if prompt_tuple and len(prompt_tuple) >= 5:
                            data = {
                                "prompt": prompt_tuple[2],
                                "extra_data": prompt_tuple[3],
                                "outputs_to_execute": prompt_tuple[4],
                                "sensitive": prompt_tuple[5] if len(prompt_tuple) > 5 else []
                            }
                            logger.info(f"Inserting missing fast-executing prompt into DB: {pid}")
                            conn.execute(
                                """
                                INSERT OR IGNORE INTO prompts (prompt_id, prompt_data, status, updated_at)
                                VALUES (?, ?, 'completed', CURRENT_TIMESTAMP)
                                """,
                                (pid, json.dumps(data))
                            )
                            conn.execute("UPDATE prompts SET status = 'completed' WHERE prompt_id = ? AND status != 'completed'", (pid,))
                        else:
                            logger.warning(f"History item {pid} has invalid prompt_tuple: {prompt_tuple}")

                conn.commit()
            
            self.last_seen_active_ids = current_active_ids
            self.last_seen_history_ids = history_ids

    def _setup_routes(self):
        routes = PromptServer.instance.routes

        @routes.get("/comfyui-persistent-queue/prompts")
        async def get_prompts(request):
            async with self.db_lock:
                with self._get_db() as conn:
                    cursor = conn.execute("SELECT prompt_id, prompt_data, status, created_at FROM prompts ORDER BY created_at DESC")
                    rows = cursor.fetchall()
                    result = []
                    for row in rows:
                        result.append({
                            "prompt_id": row[0],
                            "prompt_data": json.loads(row[1]),
                            "status": row[2],
                            "created_at": row[3]
                        })
                    return web.json_response(result)

        @routes.get("/comfyui-persistent-queue/config")
        async def get_config_route(request):
            return web.json_response(self.get_config())

        @routes.post("/comfyui-persistent-queue/config")
        async def post_config_route(request):
            data = await request.json()
            if "auto_load" in data:
                self.set_config(data["auto_load"])
            return web.json_response({"success": True})

        @routes.post("/comfyui-persistent-queue/delete")
        async def delete_prompt(request):
            data = await request.json()
            prompt_id = data.get("prompt_id")
            async with self.db_lock:
                with self._get_db() as conn:
                    conn.execute("DELETE FROM prompts WHERE prompt_id = ?", (prompt_id,))
                    conn.commit()
            return web.json_response({"success": True})

        @routes.post("/comfyui-persistent-queue/clear_history")
        async def clear_history(request):
            async with self.db_lock:
                with self._get_db() as conn:
                    conn.execute("DELETE FROM prompts WHERE status = 'completed'")
                    conn.commit()
            return web.json_response({"success": True})
