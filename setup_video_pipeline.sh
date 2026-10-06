#!/bin/bash
# Set up the video pipeline in the ai-video-pipeline repo
# Run this on the Vast.ai instance
set -euo pipefail

PIPELINE_DIR="/workspace/ai-video-pipeline"
cd "$PIPELINE_DIR"

echo "Setting up video pipeline..."

# Copy auto_stitch.py from local or create it here
if [ ! -f "auto_stitch.py" ]; then
    echo "Downloading auto_stitch.py from your diffusion repo..."
    # Placeholder: user will copy it manually or via git
    echo "TODO: copy auto_stitch.py to $PIPELINE_DIR"
fi

# Create directories for clips and output
mkdir -p clips output logs

# Set up git if not already done
if [ ! -f ".git/config" ]; then
    git init
    git config user.name "AI Video Pipeline"
    git config user.email "pipeline@vast.ai"
fi

# Create a basic workflow template for testing
cat > workflow_template.json <<'EOF'
{
  "1": {
    "inputs": {
      "ckpt_name": "wan21_model.safetensors"
    },
    "class_type": "CheckpointLoader",
    "_meta": {}
  },
  "2": {
    "inputs": {
      "text": "a person speaking"
    },
    "class_type": "CLIPTextEncode",
    "_meta": {}
  }
}
EOF

echo "✓ Video pipeline directories created:"
echo "  Clips: $PIPELINE_DIR/clips/"
echo "  Output: $PIPELINE_DIR/output/"
echo ""
echo "Next steps:"
echo "  1. Place 5-second video clips in ./clips/"
echo "  2. Place master audio in ./clips/master.wav"
echo "  3. Run: python auto_stitch.py clips/ --audio master.wav -o output/final.mp4"
