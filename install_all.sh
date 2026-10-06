#!/bin/bash
# Master install script for Vast.ai video pipeline
# Run this once to set up everything
set -euo pipefail

echo "🚀 Installing AI Video Diffusion Pipeline on Vast.ai..."
echo ""

# Step 1: LivePortrait
echo "Step 1: Installing LivePortrait custom node..."
bash /workspace/ai-video-pipeline/install_liveportrait.sh
echo ""

# Step 2: Wan 2.1 model
echo "Step 2: Downloading Wan 2.1 model weights..."
bash /workspace/ai-video-pipeline/download_wan21.sh
echo ""

# Step 3: Video pipeline setup
echo "Step 3: Setting up video pipeline..."
bash /workspace/ai-video-pipeline/setup_video_pipeline.sh
echo ""

echo "✅ Setup complete!"
echo ""
echo "Your instance is ready:"
echo "  - ComfyUI: /workspace/ComfyUI"
echo "  - LivePortrait node: /workspace/ComfyUI/custom_nodes/ComfyUI-LivePortrait"
echo "  - Wan 2.1 model: ~/models/wan21"
echo "  - Video pipeline: /workspace/ai-video-pipeline"
echo ""
echo "To start ComfyUI:"
echo "  cd /workspace/ComfyUI && python main.py"
