# PoesIA on Apertus

Hack Apertus 2026, Track 2B (own project). A private, on-premise page for letting things out
in poetry, in Spanish, English and Italian: the person writes what they felt and shapes it into a poem line by line, in their
own words. Apertus v1.5 8B proposes only when asked; a deterministic engine counts syllables,
stress and rhyme and explains them; the person decides and stays the author. A safety screen
pauses the poem and shows Swiss support services when a reflection signals risk. Nothing
leaves the machine.

The project lives in [`track_2b/`](track_2b/) (template layout):

| Path | What it is |
|---|---|
| `track_2b/Makefile` | `make run` starts the model and the page in Docker |
| `track_2b/docker-compose.yml` | Ollama (Apertus), a one-shot model setup, the PoesIA page |
| `track_2b/src/` | the page image and the Ollama model definition |
| `track_2b/technical_report.md` | architecture, evaluation, limitations |
| `track_2b/README.md` | the organisers' Track 2B description, unchanged |

## Run it

From `track_2b/`, one command; the GPU is used when Docker has the NVIDIA runtime:

| System | Command |
|---|---|
| Windows (PowerShell) | `.\run.ps1` |
| Linux, macOS, WSL | `./run.sh` |
| with `make` | `make run` |
| CPU only, plain Docker | `docker compose up` |

Then open http://localhost:8000. The first run downloads the model (~5 GB) and the
embedding model (~1.2 GB) once; after that no network is needed. Add `-d` (`-Detach` in
PowerShell) to run in the background; stop with `docker compose down` (`make stop`).

With an existing Apertus endpoint instead of the local model (OpenAI-compatible API), only the
page starts:

```bash
LLM_BASE_URL=https://.../v1 LLM_NAME=<apertus model id> LLM_API_KEY=... ./run.sh
```

Requirements: Docker with Compose v2. An NVIDIA GPU with 6 GB or more is used when available;
without one the model runs on CPU (a suggestion takes about 15 s instead of 2).

## Credits

- Model: Apertus v1.5 8B (Swiss AI Initiative), text backbone by Andreas Martin
  (`andreasmartin/apertus-v1.5-8b-text`), GGUF conversion `Colby/apertus-v1.5-8b-text-Q4_K_M-GGUF`.
- Embeddings: BAAI `bge-m3` (MIT).
- Voices (Piper, rhasspy/piper-voices): Spanish *davefx* (CC0), English *LJ Speech* (public
  domain), Italian *Serena* (CC BY 4.0).
- Poems offered by the page: see `track_2b/data/linking/README.md` (public domain, CC0, and
  DISCO, CC BY 4.0).

## Licence

Apache-2.0 (this repository). The engine, [PoesIA](https://github.com/OomAngel/poesia), is
MIT. Apertus v1.5 is Apache-2.0 under the Apertus Acceptable Use Policy.
