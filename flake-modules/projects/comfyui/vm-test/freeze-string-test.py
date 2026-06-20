import urllib.request
import json
import time
import sys

PORT = 8189
URL_PROMPT = f"http://127.0.0.1:{PORT}/prompt"
URL_QUEUE = f"http://127.0.0.1:{PORT}/queue"
URL_HISTORY = f"http://127.0.0.1:{PORT}/history"

def queue_and_wait(prompt):
    p = {"prompt": prompt}
    data = json.dumps(p).encode("utf-8")
    req = urllib.request.Request(URL_PROMPT, data=data)
    with urllib.request.urlopen(req) as response:
        res = json.loads(response.read().decode("utf-8"))
        prompt_id = res["prompt_id"]
    
    print(f"Queued prompt: {prompt_id}")
    
    # Wait for execution to complete
    while True:
        req_queue = urllib.request.Request(URL_QUEUE)
        with urllib.request.urlopen(req_queue) as resp:
            q = json.loads(resp.read().decode("utf-8"))
            running = q.get("queue_running", q.get("running", []))
            pending = q.get("queue_pending", q.get("pending", []))
            # Flatten or match prompt_id
            all_ids = []
            for item in running + pending:
                if isinstance(item, list):
                    all_ids.extend(item)
                elif isinstance(item, dict):
                    all_ids.append(item.get("prompt_id"))
                else:
                    all_ids.append(item)
            if prompt_id not in all_ids:
                break
        time.sleep(0.5)
        
    # Get history
    req_hist = urllib.request.Request(f"{URL_HISTORY}/{prompt_id}")
    with urllib.request.urlopen(req_hist) as resp:
        history = json.loads(resp.read().decode("utf-8"))
        entry = history[prompt_id]
        if "error" in entry:
            raise Exception(f"Execution failed with error: {entry['error']}")
        return entry

# Case 1: freeze = False -> output should be text_input ("hello dynamic")
prompt_unfrozen = {
    "1": {
        "inputs": {
            "text_input": "hello dynamic",
            "freeze": False,
            "frozen_text": "hello frozen"
        },
        "class_type": "FreezeStringNode"
    },
    "2": {
        "inputs": {
            "text": ["1", 0]
        },
        "class_type": "TestOutputNode"
    }
}

print("Running Case 1: Unfrozen text input")
result_unfrozen = queue_and_wait(prompt_unfrozen)
outputs_unfrozen = result_unfrozen["outputs"]["2"]["text"]
print(f"Case 1 outputs: {outputs_unfrozen}")
assert outputs_unfrozen == ["hello dynamic"], f"Expected ['hello dynamic'], got {outputs_unfrozen}"

# Case 2: freeze = True -> output should be frozen_text ("hello frozen")
prompt_frozen = {
    "1": {
        "inputs": {
            "text_input": "hello dynamic",
            "freeze": True,
            "frozen_text": "hello frozen"
        },
        "class_type": "FreezeStringNode"
    },
    "2": {
        "inputs": {
            "text": ["1", 0]
        },
        "class_type": "TestOutputNode"
    }
}

print("Running Case 2: Frozen text input")
result_frozen = queue_and_wait(prompt_frozen)
outputs_frozen = result_frozen["outputs"]["2"]["text"]
print(f"Case 2 outputs: {outputs_frozen}")
assert outputs_frozen == ["hello frozen"], f"Expected ['hello frozen'], got {outputs_frozen}"

print("All tests passed successfully!")
sys.exit(0)
