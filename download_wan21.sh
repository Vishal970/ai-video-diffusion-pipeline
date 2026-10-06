#!/bin/bash
# Download Wan 2.1 video model weights
# Run this on the Vast.ai instance
set -euo pipefail

MODEL_DIR="$HOME/models"
mkdir -p "$MODEL_DIR"

echo "Downloading Wan 2.1 model weights..."

# Wan 2.1 is typically on HuggingFace
# Adjust the repo ID if different
cd "$MODEL_DIR"

# Using huggingface-hub CLI
pip install huggingface-hub >/dev/null 2>&1

# Option 1: If Wan 2.1 is on HuggingFace (adjust repo as needed)
HF_REPO="alibaba-pai/Wan2.1-Diffusion-Video"
echo "Downloading from $HF_REPO..."

huggingface-cli download "$HF_REPO" --repo-type model --local-dir ./wan21 || {
    echo "Failed to download from HuggingFace. Check the repo ID."
    echo "You may need to:"
    echo "  1. Accept the model license on HuggingFace"
    echo "  2. Use huggingface-cli login if it's gated"
    exit 1
}

echo "✓ Wan 2.1 model downloaded to $MODEL_DIR/wan21"
echo "  Set ComfyUI checkpoint path to: $MODEL_DIR/wan21"
