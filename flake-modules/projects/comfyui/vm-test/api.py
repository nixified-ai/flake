import json
import argparse
from urllib import request
import sys

# Parse command-line arguments
parser = argparse.ArgumentParser(description="Queue a prompt to a specific port.")
parser.add_argument("file_path", help="Path to the file containing the prompt JSON.")
parser.add_argument("--port", type=int, default=8188, help="Port number to send the request to (default: 8188).")
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
    request.urlopen(req)

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
        if class_type in object_info:
            filtered_prompt[node_id] = node_data
            registered_custom_nodes_count += 1

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
    queue_prompt(filtered_prompt, args.port)
    print("Success: Prompt successfully queued.")
except Exception as e:
    print(f"Error: Failed to queue prompt: {e}", file=sys.stderr)
    sys.exit(1)
