#!/usr/bin/env bash
# Run on the Vast.ai instance. Reads the PAT from the environment so it never
# lands in shell history, this repo, or a remote URL.
#   export GITHUB_TOKEN=...   # fine-grained PAT, Contents: read/write, this repo only
#   ./setup_github.sh <github-user> ai-video-diffusion-pipeline
set -euo pipefail
user="${1:?github username}"; repo="${2:-ai-video-diffusion-pipeline}"
: "${GITHUB_TOKEN:?export GITHUB_TOKEN first}"

git config --global credential.helper 'store --file ~/.git-credentials'
umask 077
printf 'https://%s:%s@github.com\n' "$user" "$GITHUB_TOKEN" > ~/.git-credentials
git remote get-url origin >/dev/null 2>&1 \
  || git remote add origin "https://github.com/${user}/${repo}.git"
echo "Configured. Test with: git push -u origin main"
