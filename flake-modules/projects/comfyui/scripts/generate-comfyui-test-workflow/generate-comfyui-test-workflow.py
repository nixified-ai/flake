#!/usr/bin/env python3
import json
import argparse
import sys
import os
import urllib.request

def normalize_url(url):
    url = url.lower().strip()
    if url.endswith(".git"):
        url = url[:-4]
    if url.endswith("/"):
        url = url[:-1]
    return url

def find_sources(specified_path):
    if specified_path:
        return specified_path
    env_path = os.environ.get("COMFYUI_SOURCES_JSON")
    if env_path and os.path.exists(env_path):
        return env_path

    # Check relative to cwd
    cwd_paths = [
        "flake-modules/projects/comfyui/customNodes-npins/sources.json",
        "customNodes-npins/sources.json",
        "./sources.json"
    ]
    for p in cwd_paths:
        if os.path.exists(p):
            return p

    # Check relative to script
    script_dir = os.path.dirname(os.path.realpath(__file__))
    rel_paths = [
        os.path.join(script_dir, "..", "..", "customNodes-npins", "sources.json"),
        os.path.join(script_dir, "..", "..", "..", "customNodes-npins", "sources.json"),
    ]
    for p in rel_paths:
        if os.path.exists(p):
            return p
    return None

def get_node_map(specified_path):
    if specified_path:
        with open(specified_path, 'r') as f:
            return json.load(f)

    env_path = os.environ.get("COMFYUI_EXTENSION_NODE_MAP")
    if env_path and os.path.exists(env_path):
        with open(env_path, 'r') as f:
            return json.load(f)

    # Try downloading
    url = "https://raw.githubusercontent.com/Comfy-Org/ComfyUI-Manager/refs/heads/main/node_db/new/extension-node-map.json"
    try:
        req = urllib.request.urlopen(url)
        return json.loads(req.read().decode('utf-8'))
    except Exception as e:
        print(f"Error: Could not download extension-node-map.json from {url}: {e}", file=sys.stderr)
        sys.exit(1)

def main():
    parser = argparse.ArgumentParser(description="Generate a test ComfyUI workflow for a given custom node.")
    parser.add_argument("custom_node_name", help="Name of the custom node package")
    parser.add_argument("--sources", help="Path to sources.json")
    parser.add_argument("--node-map", dest="node_map", help="Path to extension-node-map.json")
    args = parser.parse_args()

    sources_path = find_sources(args.sources)
    if not sources_path or not os.path.exists(sources_path):
        print(f"Error: Could not find sources.json. Use --sources to specify the path.", file=sys.stderr)
        sys.exit(1)

    with open(sources_path, 'r') as f:
        sources_data = json.load(f)
    pins = sources_data.get("pins", sources_data)

    if args.custom_node_name not in pins:
        print(f"Error: Custom node '{args.custom_node_name}' not found in {sources_path}", file=sys.stderr)
        sys.exit(1)

    node_info = pins[args.custom_node_name]
    repo_url = None
    if "repository" in node_info:
        repo = node_info["repository"]
        if repo.get("type") == "GitHub":
            repo_url = f"https://github.com/{repo['owner']}/{repo['repo']}"
        elif repo.get("type") == "GitLab":
            server = repo.get("server", "https://gitlab.com/")
            if not server.endswith("/"):
                server += "/"
            repo_url = f"{server}{repo['repo_path']}"
        elif "url" in repo:
            repo_url = repo["url"]

    if not repo_url and "url" in node_info:
        url = node_info["url"]
        if "github.com" in url:
            if "api.github.com/repos/" in url:
                parts = url.split("api.github.com/repos/")[1].split("/")
                if len(parts) >= 2:
                    repo_url = f"https://github.com/{parts[0]}/{parts[1]}"
            else:
                parts = url.split("github.com/")[1].split("/")
                if len(parts) >= 2:
                    repo_url = f"https://github.com/{parts[0]}/{parts[1]}"
        elif "gitlab.com" in url:
            if "api/v4/projects/" in url:
                project = url.split("api/v4/projects/")[1].split("/")[0]
                project = project.replace("%2F", "/")
                repo_url = f"https://gitlab.com/{project}"
            else:
                parts = url.split("gitlab.com/")[1].split("/")
                if len(parts) >= 2:
                    repo_url = f"https://gitlab.com/{parts[0]}/{parts[1]}"

    if not repo_url:
        print(f"Error: Could not determine repository URL for '{args.custom_node_name}'", file=sys.stderr)
        sys.exit(1)

    node_map = get_node_map(args.node_map)
    normalized_repo_url = normalize_url(repo_url)

    nodes = None
    found_repo = False
    for url, data in node_map.items():
        if normalize_url(url) == normalized_repo_url:
            nodes = data[0]
            found_repo = True
            break

    if not found_repo:
        print(f"Error: Could not find nodes for {repo_url} in extension-node-map.json", file=sys.stderr)
        sys.exit(1)

    workflow = {}
    for i, node_type in enumerate(nodes):
        workflow[str(i + 1)] = {
            "class_type": node_type,
            "inputs": {}
        }

    # Append dummy output node to satisfy ComfyUI's output node validation
    workflow["dummy_output"] = {
        "class_type": "DummyOutputNode",
        "inputs": {}
    }

    print(json.dumps(workflow, indent=2))

if __name__ == "__main__":
    main()
