import json
from urllib import request
import sys

# Get the file path from the first command-line argument
file_path = sys.argv[1]

# Read the file
with open(file_path, 'r') as file:
    prompt_text = file.read()

def queue_prompt(prompt):
    p = {"prompt": prompt}
    data = json.dumps(p).encode('utf-8')
    req = request.Request("http://127.0.0.1:8188/prompt", data=data)
    request.urlopen(req)

prompt = json.loads(prompt_text)

queue_prompt(prompt)


