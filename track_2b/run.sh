#!/usr/bin/env sh
# Start PoesIA: the model and the page, on the GPU when Docker has the NVIDIA runtime.
#   ./run.sh            then open http://localhost:8000 (first run downloads ~6 GB)
#   ./run.sh -d         same, in the background (stop with: docker compose down)
# With your own Apertus endpoint (OpenAI-compatible) instead of the local model:
#   LLM_BASE_URL=https://.../v1 LLM_NAME=<model> LLM_API_KEY=... ./run.sh
set -eu
cd "$(dirname "$0")"
DOCKER="${DOCKER:-docker}"
files="-f docker-compose.yml"
if "$DOCKER" info --format '{{json .Runtimes}}' 2>/dev/null | grep -q nvidia; then
  files="$files -f docker-compose.gpu.yml"
  echo "NVIDIA GPU runtime found: the model runs on the GPU."
else
  echo "No NVIDIA GPU runtime: the model runs on the CPU (a suggestion takes ~15 s)."
fi
if [ -n "${LLM_BASE_URL:-}" ]; then
  echo "Using the endpoint in LLM_BASE_URL; the local model is not started."
  # Hand the endpoint to compose in a file, not the environment: a Windows docker.exe called
  # from WSL does not inherit WSL's variables. The file can hold the API key, so it is
  # private to this user, git-ignored (.env.*), and removed when this script exits.
  umask 077
  trap 'rm -f .env.run' EXIT INT TERM
  for v in LLM_BASE_URL LLM_NAME LLM_API_KEY EMBED_BASE_URL EMBED_NAME EMBED_API_KEY; do
    eval "val=\${$v:-}"
    [ -n "$val" ] && printf '%s=%s\n' "$v" "$val"
  done > .env.run
  # shellcheck disable=SC2086
  "$DOCKER" compose --env-file .env.run $files up --build --no-deps "$@" web
  exit $?
fi
# shellcheck disable=SC2086
exec "$DOCKER" compose $files up --build "$@"
