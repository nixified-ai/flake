#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PROJECT_DIR=$(cd "$SCRIPT_DIR/.." && pwd)

MANAGER_NPINS_DIR="$PROJECT_DIR/manager-npins"
mkdir -p "$MANAGER_NPINS_DIR"
if [ ! -f "$MANAGER_NPINS_DIR/sources.json" ]; then
    (cd "$MANAGER_NPINS_DIR" && npins -d . init)
fi

# Find the ComfyUI-Manager outPath using nix
echo "Resolving ComfyUI-Manager pin..."
MANAGER_OUT_PATH=$(nix eval --impure --raw --expr "(import $PROJECT_DIR/customNodes-npins/default.nix {}).ComfyUI-Manager.outPath")
NODE_LIST_JSON="$MANAGER_OUT_PATH/comfyui_manager/custom-node-list.json"

if [ ! -f "$NODE_LIST_JSON" ]; then
    echo "Could not find custom-node-list.json at $NODE_LIST_JSON"
    exit 1
fi

EXISTING_PINS=$(jq -r '.pins | keys[]' "$MANAGER_NPINS_DIR/sources.json" 2>/dev/null || echo "")

echo "Syncing nodes from ComfyUI-Manager..."

# Iterate over all nodes
jq -c '.custom_nodes[]' "$NODE_LIST_JSON" | while read -r node; do
    install_type=$(echo "$node" | jq -r '.install_type // "git-clone"')
    if [ "$install_type" != "git-clone" ]; then
        continue
    fi

    files_type=$(echo "$node" | jq -r '.files | type')
    if [ "$files_type" == "array" ]; then
        url=$(echo "$node" | jq -r '.files[0]')
    else
        url=$(echo "$node" | jq -r '.files')
    fi
    
    if [[ -z "$url" || "$url" == "null" ]]; then
        url=$(echo "$node" | jq -r '.reference')
    fi

    if [[ "$url" =~ ^https://(github\.com|gitlab\.com)/([^/]+)/([^/.]+)(\.git)?/?$ ]]; then
        DOMAIN="${BASH_REMATCH[1]}"
        OWNER="${BASH_REMATCH[2]}"
        REPO="${BASH_REMATCH[3]}"
        
        if [[ "$DOMAIN" == "gitlab.com" ]]; then
            PROVIDER="gitlab"
        else
            PROVIDER="github"
        fi
    else
        PROVIDER="git"
    fi
    
    # Extract name from repo
    if [ "$PROVIDER" != "git" ]; then
        REPO_NAME="$REPO"
    else
        REPO_NAME=$(basename "$url" .git)
    fi

    NAME=$(echo "$REPO_NAME" | tr '[:upper:]' '[:lower:]' | tr '_' '-')
    if [[ ! "$NAME" == comfyui-manager-* ]]; then
        if [[ "$NAME" == comfyui-* ]]; then
            NAME="comfyui-manager-${NAME#comfyui-}"
        else
            NAME="comfyui-manager-$NAME"
        fi
    fi

    if echo "$EXISTING_PINS" | grep -qx "$NAME"; then
        continue
    fi

    if [ "$PROVIDER" != "git" ]; then
        echo "Adding $NAME ($url)..."
        
        # Use git ls-remote to avoid GitHub API rate limits
        BRANCH=$(git ls-remote --symref "$url" HEAD 2>/dev/null | awk '/^ref:/ {sub("refs/heads/", "", $2); print $2}' | head -n 1)
        if [ -z "$BRANCH" ]; then
            echo "Failed to detect default branch for $url, falling back to 'main'"
            BRANCH="main"
        fi

        (cd "$MANAGER_NPINS_DIR" && npins -d . add "$PROVIDER" "$OWNER" "$REPO" --name "$NAME" -b "$BRANCH") || echo "Failed to add $NAME"
    else
        echo "Adding $NAME (git url: $url)..."
        (cd "$MANAGER_NPINS_DIR" && npins -d . add git "$url" --name "$NAME") || echo "Failed to add $NAME"
    fi
done

echo "Sync complete!"
