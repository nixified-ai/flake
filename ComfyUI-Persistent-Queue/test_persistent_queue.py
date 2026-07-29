import pytest
from unittest.mock import MagicMock, patch
import sqlite3
import os
import sys

# Mock ComfyUI modules before importing our node
sys.modules['folder_paths'] = MagicMock()
sys.modules['server'] = MagicMock()
sys.modules['aiohttp'] = MagicMock()
sys.modules['aiohttp.web'] = MagicMock()

from persistent_queue import PersistentQueueManager  # noqa: E402

@pytest.fixture
def mock_server():
    server = MagicMock()
    server.number = 1
    
    queue_mock = MagicMock()
    queue_mock.mutex = MagicMock()
    queue_mock.mutex.__enter__ = MagicMock(return_value=None)
    queue_mock.mutex.__exit__ = MagicMock(return_value=None)
    
    # Defaults
    queue_mock.get_current_queue_volatile.return_value = ([], [])
    queue_mock.get_history.return_value = {}
    
    server.prompt_queue = queue_mock
    
    routes_mock = MagicMock()
    routes_mock.get = MagicMock(return_value=lambda f: f)
    routes_mock.post = MagicMock(return_value=lambda f: f)
    server.routes = routes_mock
    
    with patch("persistent_queue.PromptServer") as mock_prompt_server:
        mock_prompt_server.instance = server
        yield server

@pytest.fixture
def manager(tmp_path, mock_server):
    with patch("persistent_queue.os.getenv", return_value=str(tmp_path)):
        with patch("persistent_queue.folder_paths.base_path", str(tmp_path)):
            mgr = PersistentQueueManager()
            yield mgr

@pytest.mark.asyncio
async def test_db_initialization(manager):
    # Verify DB is created
    assert os.path.exists(manager.db_path)
    with sqlite3.connect(manager.db_path) as conn:
        cursor = conn.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='prompts'")
        assert cursor.fetchone() is not None

@pytest.mark.asyncio
async def test_sync_new_prompt(manager, mock_server):
    # Simulate a new prompt being added to ComfyUI's queue
    mock_server.prompt_queue.get_current_queue_volatile.return_value = (
        [], # running
        [(1, "prompt_1", {"some": "data"}, {}, [], [])] # queued
    )
    
    await manager._perform_sync()
    
    with sqlite3.connect(manager.db_path) as conn:
        cursor = conn.execute("SELECT prompt_id, status FROM prompts")
        rows = cursor.fetchall()
        assert len(rows) == 1
        assert rows[0][0] == "prompt_1"
        assert rows[0][1] == "queued"

@pytest.mark.asyncio
async def test_sync_completed_prompt(manager, mock_server):
    # Insert a fake active prompt
    manager.last_seen_active_ids = {"prompt_1"}
    with sqlite3.connect(manager.db_path) as conn:
        conn.execute("INSERT INTO prompts (prompt_id, status) VALUES ('prompt_1', 'running')")
        conn.commit()
    
    # Simulate ComfyUI now having an empty active queue, but it's in history
    mock_server.prompt_queue.get_current_queue_volatile.return_value = ([], [])
    mock_server.prompt_queue.get_history.return_value = {"prompt_1": {}}
    
    await manager._perform_sync()
    
    with sqlite3.connect(manager.db_path) as conn:
        cursor = conn.execute("SELECT prompt_id, status FROM prompts")
        rows = cursor.fetchall()
        assert len(rows) == 1
        assert rows[0][1] == "completed"

@pytest.mark.asyncio
async def test_sync_deleted_prompt(manager, mock_server):
    # Insert a fake active prompt
    manager.last_seen_active_ids = {"prompt_1"}
    with sqlite3.connect(manager.db_path) as conn:
        conn.execute("INSERT INTO prompts (prompt_id, status) VALUES ('prompt_1', 'queued')")
        conn.commit()
    
    # Simulate ComfyUI now having an empty active queue, and NOT in history
    mock_server.prompt_queue.get_current_queue_volatile.return_value = ([], [])
    mock_server.prompt_queue.get_history.return_value = {}
    
    await manager._perform_sync()
    
    with sqlite3.connect(manager.db_path) as conn:
        cursor = conn.execute("SELECT prompt_id, status FROM prompts")
        rows = cursor.fetchall()
        assert len(rows) == 0  # It was deleted
