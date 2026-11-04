#!/usr/bin/env bash

# Define the root of the custom node directory relative to script path
custom_node_dir="$(dirname "$0")"

# Create web directory
mkdir -p "${custom_node_dir}/web"

# Initialize empty files if they do not exist
touch "${custom_node_dir}/__init__.py"
touch "${custom_node_dir}/freeze_string.py"
touch "${custom_node_dir}/web/freeze_string.js"

echo "Directory structure and files verified/initialized in '${custom_node_dir}'."
