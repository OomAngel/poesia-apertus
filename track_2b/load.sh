#!/usr/bin/env sh
# Restore a PoesIA bundle made by ./bundle.sh, with no network. Then: ./run.sh --offline
#   ./load.sh [folder]     default: the folder this script is in, else poesia-bundle/
set -eu
here="$(cd "$(dirname "$0")" && pwd)"
DOCKER="${DOCKER:-docker}"
if [ -n "${1:-}" ]; then src="$1"; elif [ -f "$here/images.tar.gz" ]; then src="$here"; else
  src="$here/poesia-bundle"; fi
cd "$src"
echo "Checking the files..."
if command -v sha256sum >/dev/null; then sha256sum -c SHA256SUMS; else shasum -a 256 -c SHA256SUMS; fi
echo "Loading the images..."
"$DOCKER" load < images.tar.gz
echo "Restoring the models..."
# The volume carries compose's labels so compose adopts it as its own; no container is made
# here (one left behind would be reused by the next start with stale network settings).
"$DOCKER" volume create --label com.docker.compose.project=poesia-apertus \
  --label com.docker.compose.volume=ollama poesia-apertus_ollama >/dev/null
ollama_image=$(sed -n 's/^ *image: *\(ollama\/ollama:.*\)$/\1/p' docker-compose.yml)
"$DOCKER" run --rm -i -v poesia-apertus_ollama:/root/.ollama --entrypoint tar "$ollama_image" \
  -C /root/.ollama -xf - < models.tar
printf "Done. Start it with ./run.sh --offline (Windows: .\\\\run.ps1 -Offline).\\n"
