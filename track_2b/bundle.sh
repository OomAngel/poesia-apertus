#!/usr/bin/env sh
# Pack PoesIA for a machine with no network: both images and the prepared models in one folder.
#   ./bundle.sh [folder]     default: poesia-bundle/  (about 10 GB)
# Run it after one normal ./run.sh has finished preparing the models. On the other machine:
#   ./load.sh [folder]  then  ./run.sh --offline      (Windows: .\load.ps1, .\run.ps1 -Offline)
set -eu
cd "$(dirname "$0")"
DOCKER="${DOCKER:-docker}"
out="${1:-poesia-bundle}"
volume=poesia-apertus_ollama
ollama_image=$(sed -n 's/^ *image: *\(ollama\/ollama:.*\)$/\1/p' docker-compose.yml)
web_image=poesia-apertus-web

"$DOCKER" image inspect "$web_image" >/dev/null 2>&1 || "$DOCKER" compose build web
models=$("$DOCKER" run --rm -v "$volume:/root/.ollama" --entrypoint sh "$ollama_image" \
  -c 'ls /root/.ollama/models/manifests/registry.ollama.ai/library 2>/dev/null' || true)
for m in poesia-apertus poesia-embed; do
  echo "$models" | grep -qx "$m" || {
    echo "The model $m is not prepared yet: run ./run.sh once and wait for 'ready'." >&2
    exit 1
  }
done

mkdir -p "$out"
echo "Saving the images (compressed; a few minutes)..."
"$DOCKER" save "$ollama_image" "$web_image" | gzip -1 > "$out/images.tar.gz"
echo "Saving the models..."
# Streamed through the Docker CLI, not a bind mount, so it also works from WSL with docker.exe.
"$DOCKER" run --rm -v "$volume:/root/.ollama:ro" --entrypoint tar "$ollama_image" \
  -C /root/.ollama -cf - models > "$out/models.tar"
cp docker-compose.yml docker-compose.gpu.yml run.sh run.ps1 load.sh load.ps1 "$out/"
(
  cd "$out"
  if command -v sha256sum >/dev/null; then sha256sum images.tar.gz models.tar; else
    shasum -a 256 images.tar.gz models.tar; fi > SHA256SUMS
)
du -sh "$out"
echo "Done. Copy $out/ to the other machine, then run ./load.sh there."
