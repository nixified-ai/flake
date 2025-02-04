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

def queue_prompt(prompt, port):
    p = {"prompt": prompt}
    data = json.dumps(p).encode('utf-8')
    req = request.Request(f"http://127.0.0.1:{port}/prompt", data=data)
    request.urlopen(req)

prompt = json.loads(prompt_text)

queue_prompt(prompt, args.port)
