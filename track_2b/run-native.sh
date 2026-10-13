#!/usr/bin/env sh
# Start PoesIA without Docker: needs only the Ollama app (https://ollama.com/download) and uv
# (https://docs.astral.sh/uv/; it fetches Python itself). Windows: .\run-native.ps1
#   ./run-native.sh     then the browser opens http://localhost:8000
# First run: installs the page (~230 MB), fetches the read-back voices (~290 MB) and, on the
# page with progress, the models into Ollama (~6 GB). After that no network is needed.
set -eu
cd "$(dirname "$0")"
# The engine at the commit this entry was tested with (same as src/Dockerfile).
POESIA_REF=272955de68f41e15754d2e123fdf9d842298f6f3
command -v uvx >/dev/null || {
  echo "uv is missing. Install it with:  curl -LsSf https://astral.sh/uv/install.sh | sh" >&2
  exit 1
}
exec uvx --python 3.13 \
  --from "poesia[web,spanish,english-scan,recitation] @ https://github.com/OomAngel/poesia/archive/$POESIA_REF.zip" \
  poesia-web --with-ollama --link-index data/linking --open "$@"
