import json
import argparse
from urllib import request
import sys
import re
import time

# Parse command-line arguments
parser = argparse.ArgumentParser(description="Queue a prompt to a specific port and verify completion.")
parser.add_argument("file_path", help="Path to the file containing the prompt JSON.")
parser.add_argument("--port", type=int, default=8188, help="Port number to send the request to (default: 8188).")
parser.add_argument("--timeout", type=int, default=1200, help="Timeout in seconds to wait for prompt completion (default: 1200).")
args = parser.parse_args()

# Read the file
with open(args.file_path, 'r') as file:
    prompt_text = file.read()

def get_object_info(port):
    req = request.Request(f"http://127.0.0.1:{port}/object_info")
    with request.urlopen(req) as response:
        return json.loads(response.read().decode('utf-8'))

def queue_prompt(prompt, port):
    p = {"prompt": prompt}
    data = json.dumps(p).encode('utf-8')
    req = request.Request(f"http://127.0.0.1:{port}/prompt", data=data)
    with request.urlopen(req) as response:
        res = json.loads(response.read().decode('utf-8'))
        return res["prompt_id"]

def is_prompt_in_queue(prompt_id, port):
    req = request.Request(f"http://127.0.0.1:{port}/queue")
    try:
        with request.urlopen(req) as response:
            queue_data = json.loads(response.read().decode('utf-8'))
    except Exception as e:
        print(f"Warning: Failed to fetch queue status: {e}", file=sys.stderr)
        return True # Assume it's still in queue to retry

    running = queue_data.get("queue_running", queue_data.get("running", []))
    pending = queue_data.get("queue_pending", queue_data.get("pending", []))

    for item in running + pending:
        if item == prompt_id:
            return True
        if isinstance(item, list) and prompt_id in item:
            return True
        if isinstance(item, dict):
            if item.get("prompt_id") == prompt_id:
                return True
            if prompt_id in item.values():
                return True
    return False

def check_prompt_status(prompt_id, port):
    req = request.Request(f"http://127.0.0.1:{port}/history/{prompt_id}")
    try:
        with request.urlopen(req) as response:
            history = json.loads(response.read().decode('utf-8'))
    except Exception as e:
        return False, f"HTTP Error fetching history: {e}"

    if not history or prompt_id not in history:
        # Check /history without ID
        req_fallback = request.Request(f"http://127.0.0.1:{port}/history")
        try:
            with request.urlopen(req_fallback) as response:
                all_history = json.loads(response.read().decode('utf-8'))
        except Exception as e:
            all_history = {}
        if prompt_id not in all_history:
            return False, f"Prompt {prompt_id} not found in history"
        entry = all_history[prompt_id]
    else:
        entry = history[prompt_id]

    if "error" in entry:
        return False, f"Execution failed with error: {entry['error']}"

    status = entry.get("status", {})
    messages = status.get("messages", [])
    for msg in messages:
        if isinstance(msg, list) and len(msg) > 0 and msg[0] == "execution_error":
            return False, f"Execution error in messages: {msg}"
        if isinstance(msg, dict) and "error" in msg:
            return False, f"Execution error in messages: {msg['error']}"

    return True, "Success"

def to_word_set(name):
    # Strip common prefix/suffix like rgthree
    name_clean = re.sub(r'\(?rgthree\)?', '', name, flags=re.IGNORECASE)
    name_clean = re.sub(r'^rgthree', '', name_clean, flags=re.IGNORECASE)
    # Split by uppercase letters (for CamelCase) and non-alphanumeric characters
    words = re.findall(r'[A-Z]?[a-z0-9]+', name_clean)
    if not words:
        words = re.split(r'[^a-zA-Z0-9]+', name_clean)
    return {w.lower() for w in words if w}

def find_registered_class(class_type, object_info):
    if class_type in object_info:
        return class_type

    # Try fuzzy/normalized matching
    class_words = to_word_set(class_type)
    if not class_words:
        return None

    for registered_name in object_info:
        reg_words = to_word_set(registered_name)
        if class_words == reg_words:
            return registered_name

    return None

prompt = json.loads(prompt_text)

try:
    # 1. Fetch currently registered node classes from ComfyUI
    object_info = get_object_info(args.port)
except Exception as e:
    print(f"Error: Could not retrieve /object_info from ComfyUI: {e}", file=sys.stderr)
    sys.exit(1)

# 2. Filter prompt nodes to only keep those that are registered in ComfyUI
filtered_prompt = {}
original_custom_nodes_count = 0
registered_custom_nodes_count = 0

for node_id, node_data in prompt.items():
    class_type = node_data.get("class_type")
    if class_type == "DummyOutputNode":
        filtered_prompt[node_id] = node_data
    else:
        original_custom_nodes_count += 1
        registered_class = find_registered_class(class_type, object_info)
        if registered_class:
            node_copy = node_data.copy()
            node_copy["class_type"] = registered_class
            filtered_prompt[node_id] = node_copy
            registered_custom_nodes_count += 1
        else:
            print(f"WARNING: Node {class_type} (id {node_id}) is not registered in ComfyUI and will be removed.", file=sys.stderr)

# 3. Assert that if the custom node package is expected to register nodes, at least one of them loaded successfully
if original_custom_nodes_count > 0 and registered_custom_nodes_count == 0:
    print(
        f"Error: None of the expected custom node classes were registered in ComfyUI. Custom node package likely failed to load.",
        file=sys.stderr,
    )
    sys.exit(1)

print(
    f"Loaded custom nodes: {registered_custom_nodes_count}/{original_custom_nodes_count} successfully registered in ComfyUI."
)

# 4. Queue the prompt with the successfully loaded node classes
try:
    prompt_id = queue_prompt(filtered_prompt, args.port)
    print(f"Success: Prompt successfully queued. Prompt ID: {prompt_id}")
except Exception as e:
    print(f"Error: Failed to queue prompt: {e}", file=sys.stderr)
    sys.exit(1)

# 5. Wait for the prompt to finish executing
print("Waiting for prompt execution to complete...")
timeout = args.timeout
start_time = time.time()
while True:
    if not is_prompt_in_queue(prompt_id, args.port):
        break
    if time.time() - start_time > timeout:
        print("Error: Timeout waiting for prompt execution to complete.", file=sys.stderr)
        sys.exit(1)
    time.sleep(1)

# 6. Check prompt status in history
success, message = check_prompt_status(prompt_id, args.port)
if not success:
    print(f"Error: Prompt execution failed: {message}", file=sys.stderr)
    sys.exit(1)

print("Success: Prompt executed successfully!")
