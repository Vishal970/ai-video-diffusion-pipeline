#!/usr/bin/env python3
"""Merge short video clips with cross-fades and attach a master audio track.

Optionally runs a lip-sync step (any CLI, e.g. Wav2Lip / LatentSync) on the
stitched video before the final mux.

Usage:
    python auto_stitch.py clips/ --audio master.wav -o final.mp4
    python auto_stitch.py clips/ --audio master.wav --fade 0.5 \
        --lipsync-cmd "python Wav2Lip/inference.py --face {video} --audio {audio} --outfile {out}"
"""
import argparse
import json
import shlex
import subprocess
import sys
import tempfile
from pathlib import Path

VIDEO_EXTS = {".mp4", ".mov", ".mkv", ".webm"}


def run(cmd):
    print("+", " ".join(shlex.quote(str(c)) for c in cmd), file=sys.stderr)
    subprocess.run(cmd, check=True)


def probe_duration(path):
    out = subprocess.run(
        ["ffprobe", "-v", "error", "-show_entries", "format=duration",
         "-of", "json", str(path)],
        check=True, capture_output=True, text=True,
    ).stdout
    return float(json.loads(out)["format"]["duration"])


def has_audio(path):
    out = subprocess.run(
        ["ffprobe", "-v", "error", "-select_streams", "a",
         "-show_entries", "stream=index", "-of", "json", str(path)],
        check=True, capture_output=True, text=True,
    ).stdout
    return bool(json.loads(out)["streams"])


def crossfade(clips, fade, fps, out):
    """Chain xfade filters across all clips (video only)."""
    if len(clips) == 1:
        run(["ffmpeg", "-y", "-i", clips[0], "-an", "-r", str(fps),
             "-c:v", "libx264", "-pix_fmt", "yuv420p", out])
        return
    durations = [probe_duration(c) for c in clips]
    inputs = []
    for c in clips:
        inputs += ["-i", str(c)]
    parts, prev, offset = [], "[0:v]", 0.0
    for i in range(1, len(clips)):
        offset += durations[i - 1] - fade
        label = f"[v{i}]"
        parts.append(
            f"{prev}[{i}:v]xfade=transition=fade:duration={fade}:offset={offset:.3f}{label}"
        )
        prev = label
    run(["ffmpeg", "-y", *inputs, "-filter_complex", ";".join(parts),
         "-map", prev, "-r", str(fps), "-c:v", "libx264",
         "-pix_fmt", "yuv420p", "-an", out])


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("clips_dir", type=Path)
    ap.add_argument("--audio", type=Path, required=True, help="master audio track")
    ap.add_argument("-o", "--output", type=Path, default=Path("final.mp4"))
    ap.add_argument("--fade", type=float, default=0.5, help="cross-fade seconds")
    ap.add_argument("--fps", type=int, default=24)
    ap.add_argument("--lipsync-cmd",
                    help="template with {video} {audio} {out}; runs before final mux")
    args = ap.parse_args()

    clips = sorted(p for p in args.clips_dir.iterdir() if p.suffix.lower() in VIDEO_EXTS)
    if not clips:
        sys.exit(f"No video clips found in {args.clips_dir}")
    if not args.audio.exists():
        sys.exit(f"Audio file not found: {args.audio}")

    with tempfile.TemporaryDirectory() as tmp:
        stitched = Path(tmp) / "stitched.mp4"
        crossfade(clips, args.fade, args.fps, str(stitched))

        video = stitched
        if args.lipsync_cmd:
            synced = Path(tmp) / "lipsynced.mp4"
            cmd = args.lipsync_cmd.format(video=stitched, audio=args.audio, out=synced)
            run(shlex.split(cmd))
            video = synced

        run(["ffmpeg", "-y", "-i", video, "-i", args.audio,
             "-map", "0:v", "-map", "1:a", "-c:v", "copy", "-c:a", "aac",
             "-shortest", args.output])
    print(f"Wrote {args.output}")


if __name__ == "__main__":
    main()
