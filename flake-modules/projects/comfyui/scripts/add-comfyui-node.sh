#!/usr/bin/env bash

if [[ -z "$1" ]]; then
    echo "Usage: $0 <repository_url>"
    exit 1
fi

URL="$1"

if [[ "$URL" =~ ^https://(github\.com|gitlab\.com)/([^/]+)/([^/.]+)(\.git)?/?$ ]]; then
    DOMAIN="${BASH_REMATCH[1]}"
    OWNER="${BASH_REMATCH[2]}"
    REPO="${BASH_REMATCH[3]}"
    
    if [[ "$DOMAIN" == "gitlab.com" ]]; then
        PROVIDER="gitlab"
    else
        PROVIDER="github"
    fi
else
    echo "Invalid URL format. Expected: https://github.com/owner/repo or https://gitlab.com/owner/repo"
    exit 1
fi

# Convert to lowercase and replace '_' with '-'
NAME=$(echo "$REPO" | tr '[:upper:]' '[:lower:]' | tr '_' '-')

# Prepend 'comfyui-' if it doesn't already start with it
if [[ ! "$NAME" == comfyui-* ]]; then
    NAME="comfyui-$NAME"
fi

echo "Adding $OWNER/$REPO as $NAME from $PROVIDER..."
# Try main branch first, fallback to master if it fails
comfyui-nodes-npins add "$PROVIDER" "$OWNER" "$REPO" --name "$NAME" -b main || \
comfyui-nodes-npins add "$PROVIDER" "$OWNER" "$REPO" --name "$NAME" -b master
