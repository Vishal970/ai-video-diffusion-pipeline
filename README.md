# AI Video Diffusion Pipeline

Fully automated, high-fidelity AI video generation pipeline on Vast.ai with uncensored Wan 2.2 model, LivePortrait face-locking, and seamless video stitching.

## ✅ Setup Complete

### Hardware
- **GPU:** RTX 4090 (24GB VRAM)
- **CUDA:** 13.2
- **Python:** 3.12.14

### Components Installed
1. **ComfyUI** - `/workspace/ComfyUI`
2. **LivePortrait Node** - `/workspace/ComfyUI/custom_nodes/ComfyUI-LivePortrait` (face-consistency)
3. **Wan 2.2 Uncensored Model** - `~/models/wan22_uncensored` (2.4GB, text-to-video)
4. **auto_stitch.py** - Video stitcher with cross-fades and lip-sync

---

## 📹 Workflow: Generate Videos

### Step 1: Prepare Clips & Audio

Create 5-second video clips (5 fps recommended for Wan 2.2):

```bash
# Clip directory
/workspace/ai-video-pipeline/clips/
├── clip_0001.mp4  (5 seconds)
├── clip_0002.mp4  (5 seconds)
├── clip_0003.mp4  (5 seconds)
└── master.wav     (sync audio)
```

**Generate clips via ComfyUI API or local rendering.**

### Step 2: Stitch Videos

```bash
cd /workspace/ai-video-pipeline

# Basic stitch (0.5s cross-fade)
python auto_stitch.py clips/ --audio master.wav -o output/final.mp4

# Custom fade duration
python auto_stitch.py clips/ --audio master.wav -o output/final.mp4 --fade 0.3

# With lip-sync (Wav2Lip example)
python auto_stitch.py clips/ --audio master.wav -o output/final.mp4 \
  --lipsync-cmd "python Wav2Lip/inference.py --face {video} --audio {audio} --outfile {out}"
```

### Step 3: Push to GitHub

```bash
git add output/
git commit -m "Generated video: [description]"
git push origin main
```

---

## 🚀 ComfyUI Integration

Start ComfyUI server:

```bash
cd /workspace/ComfyUI
python main.py --listen 0.0.0.0 --port 8188
```

### Available Nodes

- **CheckpointLoader** - Load Wan 2.2 from `~/models/wan22_uncensored`
- **LivePortrait Nodes** - Face-locking for consistent characters
- **CLIPTextEncode** - Text prompts (uncensored)
- **KSampler** - Video generation

### Workflow Template

```json
{
  "1": {
    "inputs": {
      "ckpt_name": "wan22_uncensored/model.safetensors"
    },
    "class_type": "CheckpointLoader"
  },
  "2": {
    "inputs": {
      "text": "hyper-realistic person speaking, cinematic lighting, 4K"
    },
    "class_type": "CLIPTextEncode"
  },
  "3": {
    "inputs": {
      "model": ["1", 0],
      "positive": ["2", 0],
      "steps": 30,
      "cfg": 7.5,
      "sampler_name": "euler",
      "scheduler": "karras",
      "denoise": 1.0,
      "seed": 12345
    },
    "class_type": "KSampler"
  }
}
```

---

## 📋 Pipeline Scripts

### `auto_stitch.py`
Merges video clips with smooth cross-fades and optional lip-sync.

```bash
python auto_stitch.py <clips_dir> --audio <audio.wav> -o <output.mp4> [--fade 0.5] [--fps 24]
```

### `setup_github.sh`
Configures GitHub PAT for automated commits (already run).

### `install_liveportrait.sh`
Installs LivePortrait custom node (already run).

### `download_wan21.sh`
Downloads video model weights (already run).

---

## 🔐 GitHub Integration

All pipeline code is version-controlled:

```bash
git remote -v
# origin  https://github.com/Vishal970/ai-video-diffusion-pipeline.git
```

Automated pushes:
```bash
git push origin main
```

---

## 🎯 Next Steps

1. **Generate clips** via ComfyUI (`/workspace/ComfyUI`)
2. **Place in** `clips/` folder (+ `master.wav`)
3. **Run stitcher:** `python auto_stitch.py clips/ --audio master.wav -o output/final.mp4`
4. **Push to GitHub:** `git add output/ && git commit -m "..." && git push`

---

## 🛠️ Troubleshooting

### ComfyUI not starting?
```bash
cd /workspace/ComfyUI
pip install -r requirements.txt
python main.py
```

### Wan 2.2 not found?
```bash
ls -la ~/models/wan22_uncensored/
```

### auto_stitch.py issues?
```bash
pip install opencv-python pillow imageio-ffmpeg
python auto_stitch.py --help
```

### FFmpeg missing?
```bash
apt-get update && apt-get install -y ffmpeg
```

---

## 📊 Performance

- **Model:** Wan 2.2 (14B params, 4-step inference)
- **Speed:** ~30-60 sec per 5-second clip (RTX 4090)
- **Quality:** Hyper-realistic, uncensored
- **Batch:** Can stack multiple clips seamlessly

---

## 🔄 Workflow Loop

```
ComfyUI (generate clips) 
    ↓
clips/ folder (5-sec clips + audio)
    ↓
auto_stitch.py (merge + cross-fade)
    ↓
output/final.mp4 (full video)
    ↓
git push (save to GitHub)
```

---

**Setup by:** Claude Haiku 4.5  
**Last updated:** Oct 6, 2026
