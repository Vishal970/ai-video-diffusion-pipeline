#!/bin/bash
# Install LivePortrait custom node for ComfyUI on Vast.ai
# Run this on the Vast.ai instance
set -euo pipefail

COMFYUI_PATH="/workspace/ComfyUI"
CUSTOM_NODES="$COMFYUI_PATH/custom_nodes"

echo "Installing LivePortrait for ComfyUI..."

cd "$CUSTOM_NODES"

# Clone the kijai ComfyUI wrapper (most reliable for ComfyUI)
if [ ! -d "ComfyUI-LivePortrait" ]; then
    git clone https://github.com/kijai/ComfyUI-LivePortrait.git
    cd ComfyUI-LivePortrait
else
    echo "ComfyUI-LivePortrait already exists, updating..."
    cd ComfyUI-LivePortrait
    git pull
fi

# Install dependencies
echo "Installing LivePortrait Python dependencies..."
pip install -e . --no-deps 2>&1 | grep -i "success\|error" || true

# Core dependencies for LivePortrait
pip install omegaconf loguru numpy opencv-python pillow imageio imageio-ffmpeg torch torchvision

echo "✓ LivePortrait installed to $CUSTOM_NODES/ComfyUI-LivePortrait"
echo "  Restart ComfyUI to load the nodes"
