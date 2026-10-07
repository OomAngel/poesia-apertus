#!/bin/sh
# One-shot: fetch the model once (needs the network), then everything runs offline.
set -e
if ! ollama show poesia-apertus >/dev/null 2>&1; then
  echo "First run: downloading Apertus v1.5 8B text, GGUF Q4_K_M (~5 GB) from Hugging Face"
  ollama pull hf.co/Colby/apertus-v1.5-8b-text-Q4_K_M-GGUF:Q4_K_M
  ollama create poesia-apertus -f /setup/Modelfile
fi
if ! ollama show poesia-embed >/dev/null 2>&1; then
  echo "First run: downloading bge-m3 (~1.2 GB) for linking poems by feeling"
  ollama pull bge-m3
  ollama create poesia-embed -f /setup/Modelfile.embed
fi
# Load both now, so the page's first suggestion doesn't wait ~50 s for the model to load.
ollama run poesia-apertus "Hola" >/dev/null
echo "models ready and loaded: poesia-apertus, poesia-embed"
