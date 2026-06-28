#!/usr/bin/env bash
set -euo pipefail

echo "Checking host machine conditions to run the GPU container test..."

if ! command -v nvidia-smi &> /dev/null; then
  echo "Error: nvidia-smi not found. This test requires an Nvidia GPU."
  exit 1
fi

if [ ! -e /dev/nvidia-uvm ] || [ ! -e /dev/nvidia-uvm-tools ] || [ ! -e /dev/nvidia0 ] || [ ! -e /dev/nvidiactl ]; then
  echo "Error: One or more /dev/nvidia* devices are missing."
  echo "The nvidia_uvm kernel module is likely not loaded."
  echo "Please run 'sudo nvidia-modprobe -u -c=0' on your host to create the necessary device nodes and try again."
  exit 1
fi

echo "Requirements met! Running the GPU container test..."
echo "This will run 'nix build .#comfyui-container-gpu-test -L' with the required extra-sandbox-paths."
echo ""

exec nix build .#comfyui-container-gpu-test -L --extra-sandbox-paths "/dev/nvidia0 /dev/nvidiactl /dev/nvidia-uvm /dev/nvidia-uvm-tools" "$@"
