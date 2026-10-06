#!/bin/sh
# One-shot: fetch the model once (needs the network), then everything runs offline.
set -e
if ollama show poesia-apertus >/dev/null 2>&1; then
  echo "poesia-apertus already present: no download"
  exit 0
fi
echo "First run: downloading Apertus v1.5 8B text, GGUF Q4_K_M (~5 GB) from Hugging Face"
ollama pull hf.co/Colby/apertus-v1.5-8b-text-Q4_K_M-GGUF:Q4_K_M
ollama create poesia-apertus -f /setup/Modelfile
echo "poesia-apertus ready"
