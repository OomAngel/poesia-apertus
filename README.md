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
| `track_2b/docker-compose.yml` | Ollama (Apertus) and the PoesIA page, which sets up the models on first run |
| `track_2b/src/` | the page image |
| `track_2b/bundle.sh`, `load.sh`, `load.ps1` | pack and restore everything for a machine without network |
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

Then open http://localhost:8000. The page opens at once; on the first run it downloads the
model (~5 GB) and the embedding model (~1.2 GB) and shows the progress. You can start writing
meanwhile; suggestions switch on when the model is ready. After that no network is needed. Add `-d` (`-Detach` in
PowerShell) to run in the background; stop with `docker compose down` (`make stop`).

With an existing Apertus endpoint instead of the local model (OpenAI-compatible API), only the
page starts:

```bash
LLM_BASE_URL=https://.../v1 LLM_NAME=<apertus model id> LLM_API_KEY=... ./run.sh
```

### Without network

For a machine with no internet (a classroom, a library), pack everything once on a machine
that has run PoesIA, then carry the folder over (about 10 GB):

| Step | Linux, macOS, WSL | Windows (PowerShell) |
|---|---|---|
| on the connected machine | `./bundle.sh` (writes `poesia-bundle/`) | from WSL or Git Bash: `./bundle.sh` |
| on the offline machine, inside the copied folder | `./load.sh`, then `./run.sh --offline` | `.\load.ps1`, then `.\run.ps1 -Offline` |

`load` checks the files against their checksums, loads the two images and restores the
prepared models; `--offline` starts without building or downloading anything. Tested
2026-10-07 by deleting the images and models, restoring from the folder, and running on a
Docker network with no route out: the page reached "ready" and scanning, safety, read-back,
linking and suggestions all answered. The Windows steps were tested the same day from a
copy in `C:\Temp` with Windows PowerShell 5.1.

Requirements:

- Docker with Compose v2.
- 8 GB of free memory (16 GB in the machine): measured 7.3 GB in use with everything loaded
  (Apertus 5.7 GB, the embedding model 1.2 GB, the page 0.34 GB).
- About 17 GB of free disk: the Ollama image 9.3 GB, the models 6.2 GB, the page image 0.6 GB.
- Optional: an NVIDIA GPU with 6 GB or more free. Without one, or when another program holds
  part of it, the model runs wholly or partly on the processor and a suggestion takes about
  15 s instead of 2; the page says so instead of slowing down silently.

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
