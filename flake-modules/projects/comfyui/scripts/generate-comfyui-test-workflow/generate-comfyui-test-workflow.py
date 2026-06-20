#!/usr/bin/env python3
import json
import argparse
import urllib.request
import os
def main():
    parser = argparse.ArgumentParser(description="Generate a test workflow for a ComfyUI custom node")
    parser.add_argument("custom_node_name", help="Name of the custom node package")
    args = parser.parse_args()

    sources_path = os.path.join(os.path.dirname(os.path.realpath(__file__)), "..", "..", "..", "customNodes-npins", "sources.json")
    if not os.path.exists(sources_path):
        sources_path = "flake-modules/projects/comfyui/customNodes-npins/sources.json"
    if not os.path.exists(sources_path):
        sources_path = "/build/sources.json"
    if not os.path.exists(sources_path):
        sources_path = "./sources.json"


    with open(sources_path, "r") as f:
        sources = json.load(f)

    if args.custom_node_name not in sources:
        print(f"Error: Custom node '{args.custom_node_name}' not found in sources.json")
        return

    # Fetch extension-node-map.json
    map_path = os.path.join(os.path.dirname(os.path.realpath(__file__)), "..", "..", "..", "customNodes-npins", "npins", "sources.json")
    if not os.path.exists(map_path):
        map_path = "flake-modules/projects/comfyui/customNodes-npins/npins/sources.json"

    with open(map_path, "r") as f:
        npins_sources = json.load(f)
    manager_path = os.path.join("/build", "ComfyUI-Manager-source")
    if not os.path.exists(manager_path):
        manager_path = "flake-modules/projects/comfyui/customNodes-npins/npins"
    map_file = os.path.join(manager_path, "node_db", "new", "extension-node-map.json")
    if not os.path.exists(map_file):
        # Try to download if missing (e.g. out of sandbox run)
        req = urllib.request.urlopen("https://raw.githubusercontent.com/Comfy-Org/ComfyUI-Manager/refs/heads/main/node_db/new/extension-node-map.json")
        node_map = json.loads(req.read())
    else:
        with open(map_file, "r") as f:
            node_map = json.load(f)


    # Find the repo URL for the custom node
    node_info = sources[args.custom_node_name]
    if "repository" in node_info:
        repo_url = node_info["repository"].get("url")
        if not repo_url:
            repo_url = f"https://github.com/{node_info['repository']['owner']}/{node_info['repository']['repo']}"
    else:
        repo_url = f"https://github.com/{node_info['owner']}/{node_info['repo']}"

    if repo_url.endswith(".git"):
        repo_url = repo_url[:-4]

    nodes = None
    for url, data in node_map.items():
        if url.endswith(".git"):
            url = url[:-4]
        if url.lower() == repo_url.lower():
            nodes = data[0]
            break

    if not nodes:
        print(f"Error: Could not find nodes for {repo_url} in extension-node-map.json")
        return

    workflow = {}

    for i, node_name in enumerate(nodes):
        workflow[str(i + 1)] = {
            "inputs": {},
            "class_type": node_name
        }

    print(json.dumps(workflow, indent=2))

if __name__ == "__main__":
    main()
