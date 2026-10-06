#!/bin/bash
echo "🚀 Starting the un-truncated model downloader..."

# Setup variables to keep URLs from wrapping or breaking
BASE_HF="https://huggingface.co"
TE_PATH="text_encoders/umt5_xxl_fp8_e4m3fn.safetensors"
MODEL_PATH="diffusion_models/wan2.1_i2v_480p_14B_fp8.safetensors"
GIT_REPO="https://github.com"

# 1. Download Text Encoder
cd /workspace/ComfyUI/models/text_encoders/
echo "Downloading UMT5 Text Encoder (FP8 optimized)..."
wget --show-progress "${BASE_HF}/${TE_PATH}"

# 2. Download Diffusion Engine
cd /workspace/ComfyUI/models/diffusion_models/
echo "Downloading Wan 2.1 Image-To-Video Engine (14B FP8)..."
wget --show-progress -O wan2.1_i2v_480p_14B_fp8.safetensors "${BASE_HF}/${MODEL_PATH}"

# 3. Install LivePortrait Node
cd /workspace/ComfyUI/custom_nodes/
echo "Cloning LivePortrait..."
if [ ! -d "ComfyUI-LivePortraitKJ" ]; then
    git clone "${GIT_REPO}"
    cd ComfyUI-LivePortraitKJ && pip install -r requirements.txt
fi

echo "✅ Success! Everything is properly downloaded."
