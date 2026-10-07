# Technical report — PoesIA on Apertus

> **Draft, 2026-10-07.** Numbers are measured; sections marked *(to do)* are not done yet.

- **Track:** Track 2B — PoesIA on Apertus
- **Event:** Online
- **Team:** PoesIA — Angel Márquez Aguilar (solo)
- **Demo:** *(to do: video link)*

## 1. Summary

People write when something moves them, and many would like to shape it into a poem, but
form is hard to learn and AI writing tools take the words away from them. PoesIA is a local
page where the person writes every line; Apertus v1.5 8B proposes lines only on request,
and a deterministic engine checks syllables, stress and rhyme against the chosen form and
explains each problem in plain language, in Spanish, English and Italian. A safety screen
runs before any shaping. On a seeded benchmark of sonnets (18 per language) Apertus behind
the engine writes 83–85% (es), 87–90% (en) and 87% (it) of lines in exact metre, the best of
the setups we measured, on one 8 GB consumer GPU with no network.

## 2. Architecture

```
browser ──► PoesIA page (FastAPI, port 8000) ──► scansion engine (deterministic, in-process)
                    │                         ├─► safety screen (phrases + one model question)
                    └──── OpenAI-compatible API ──► Ollama ──► Apertus v1.5 8B text (GGUF Q4_K_M)
```

- **Page** (`poesia.webapp`): one language per session (es, en, it) and four steps (what
  moved you → the form → write → listen and keep). Every line is a text field the author
  fills, scanned as they type (`/api/scan`) and shown as syllables (*la·LU·na‿i·lu·MI·na*).
  "Ideas" first offers common words that rhyme with the line's partner, from offline word
  lists, each with why it fits (`/api/words`); whole lines from Apertus come only on a second
  click (`/api/propose`), ranked by the scan, not by model likelihood, and shown greyed until
  used or edited. Each line records its origin; "Keep" saves text, a printable page or a file
  to reopen, with the statement "N of M lines worded by the author". Drafts live in the tab.
- **Engine** (`poesia` package, Spanish, English and Italian): metrical syllable count with
  synalepha and final-stress rules, stress pattern, rhyme key; explanations from
  `poesia.teaching`. Forms on the page: Spanish *soneto*, English Shakespearean sonnet,
  Italian *sonetto*, haiku.
- **Read-back**: Piper, offline, three stock voices with clear licences (es CC0, en public
  domain, it CC BY 4.0: *Serena*, from rhasspy/piper-voices), labelled "synthetic voice"; no
  cloning.
- **Linking**: 3,000 poems each for es and en and 609 for it (Project Gutenberg books
  fetched for this purpose), all public domain or CC BY (credits in
  `data/linking/README.md`), matched by `bge-m3` embeddings on CPU, offered after writing.
- **Model**: Apertus v1.5 8B text backbone, served by Ollama 0.34.4.

### Target architecture

**a) On-premise and b) air-gapped.** Everything runs on one machine, bound to
`127.0.0.1`. `run.sh` / `run.ps1` (or plain `docker compose up`) start Ollama and the page;
on first run the page downloads and prepares the models itself and shows the progress, and
says when the model runs on the processor. For a machine with no network, `bundle.sh` packs
both images and the prepared models (9.6 GB, with checksums) and `load.sh` / `load.ps1`
restore them; tested by deleting images and models, restoring, and running on a Docker
network with no route out (page, scan, safety, read-back, linking and suggestions all
answered), and on Windows PowerShell 5.1. Without Docker, `run-native.sh` / `.ps1` start the
page with only the Ollama app and uv installed (no compiler, no git).

## 3. Use of Apertus

- **Model:** `andreasmartin/apertus-v1.5-8b-text` (the official `swiss-ai/Apertus-v1.5-8B`
  with its image and audio towers removed), GGUF Q4_K_M (`Colby/apertus-v1.5-8b-text-Q4_K_M-GGUF`,
  4.8 GB; our own conversion with llama.cpp `4df29be` gave the same size to within 96 bytes).
- **How it is used:** inference only. (1) Line proposals: the engine builds a prompt with
  the poem so far, the syllable target and the rhyme to match; (2) line repair; (3) one
  yes/no safety question.
- **Where it runs:** local Ollama, 5.4 GB of GPU memory on an RTX 3070 (8 GB). Any
  OpenAI-compatible Apertus endpoint can replace it (`LLM_BASE_URL`, `LLM_NAME`, `LLM_API_KEY`).
- **Prompting detail that mattered:** with a rhyme word bank in the prompt, Apertus answered
  with the rhyme word alone ("more", "floor") in 6 of 6 seeded tries; a one-sentence system
  message ("…exactly one complete line of poetry… never a single word") brought that to 0 of 6.
  The Ollama Modelfile uses Apertus's chat format with deliberation disabled.

## 4. Data

- **At runtime:** none. The person's reflection and lines go only to the local model and are
  not stored or logged.
- **Safety test set** (`data/safety` in the engine repository; dataset card there):
  60 synthetic reflections, 12 per language (es, en, de, fr, it): 20 ordinary, 20 sad but
  safe (grief, loneliness, autumn), 20 with a risk signal. No real person's text.
  *(to do: publish on Hugging Face with the organisers' template.)*
- **Evaluation gold** for the syllable counter: ADSO, 100 Spanish poems scanned by experts
  (CC BY-NC 4.0), used only to measure the counter.

## 5. Evaluation

**Metre and rhyme.** 6 themes × 3 seeds per language; Spanish *soneto* (11 syllables,
ABBA ABBA CDC DCD), English Shakespearean sonnet (10, ABAB CDCD EFEF GG). Per line: syllables
off target, share of lines in exact metre, share of rhyme pairs that hold. Same harness and
seeds for every row; all rows scored by the same engine version.

| Setup | es off/line | es metre | es rhyme | en off/line | en metre | en rhyme |
|---|---|---|---|---|---|---|
| Qwen2.5-1.5B + July 2026 adapter | 0.63 | 57% | 3% | 0.35 | 73% | 11% |
| Qwen3-4B, plain | 0.52 | 62% | 30% | 0.69 | 56% | 72% |
| Qwen3-4B + corpus adapter | 0.38 | 71% | 24% | 0.46 | 75% | 40% |
| Apertus 8B, raw prompt (transformers) | 0.83 | 60% | 41% | 0.73 | 77% | 83% |
| **Apertus 8B, Ollama, line system message** | 0.42 | **82%** | **44%** | **0.29** | **89%** | 83% |
| same, plus dropping one- and two-word candidates | 0.28 | **85%** | 33% | 0.37 | 87% | 86% |
| same, plus re-asking without the word bank when a batch is all bare words | **0.21** | 83% | 36% | **0.10** | **90%** | **88%** |

**Italian** (Petrarchan *sonetto*, 11 syllables, ABBA ABBA CDE CDE; same harness, 6 themes ×
3 seeds, Apertus via Ollama with the retry): **0.16 off per line, 87% of lines in metre, 43%
of rhyme pairs**.

The last three rows differ by about their seed noise in metre and Spanish rhyme (single
poems range from 0% to 100% rhyme), so we report all three. What the last change clearly
did: lines that were only a rhyme word went from 9 (es) and 5 (en) to none. The benchmark's Spanish rhyme word bank comes
from an online service (Datamuse); the deployed page sends none, so it runs offline.

**Safety screen** (risk recall on 20, false alarms on 40 safe):

| | before tuning | after adding conjugated forms |
|---|---|---|
| phrase list | 11/20, 0/40 | 19/20, 0/40 |
| Apertus yes/no | 13/20, 0/40 | (not tuned) |
| either (the screen) | 18/20, 0/40 | 20/20, 0/40 |

The phrase list and the test set were written by the same hand, so the tuned numbers are
optimistic; the set is a regression test, not a validation.

**Speed** (same `make run` stack):

| | RTX 3070 8 GB | CPU only (Ryzen 9 5900X, Docker Desktop) |
|---|---|---|
| rhyme words (word lists, no model) | ≤0.6 s first per language, then instant | same |
| a suggestion (6 candidates generated, best 3 shown) | 1.4–5 s | 13–15 s |
| safety screen | <1 s | 2.0 s |
| linking (embed + search) | 3.1 s | 3.2 s |
| first suggestion after `make run` (model preloaded) | 1.9 s | — |

CPU-only memory with everything loaded: 7.3 GB. A fully automatic sonnet (the benchmark
loop) takes ~35 s on the GPU. Energy, GPU board only
(`nvidia-smi` once a second over 18 Italian sonnets): ~160 W while generating, **1.7 Wh per
automatic sonnet**; a single on-request suggestion (~2 s) is under 0.1 Wh.

**Accessibility and robustness** (ux-audit, our own browser-driven audit library, and
Playwright): the five page-level layers pass (positive control: its broken fixture is
flagged); a reload keeps the reflection and the lines; every button is reachable by keyboard;
the safety pause opens on its heading, keeps Tab inside, closes with Escape and returns focus.
Defects found and fixed: changing the form cleared the lines without asking; and revealing
the next stanza redrew the page 350 ms after typing, so fast typing on line 2 went into
line 1 (reproduced on the old code, "y el v" left in line 2).

**Model server.** Same GGUF and card, through the page's own client: llama.cpp's server
(b11459) scores the same as Ollama within run-to-run noise (es 84% vs 84% metre, en 92% vs
89%, it 85% vs 83%), answers a three-line suggestion in 0.63 s vs 1.05 s, and its image is
2.59 GB (0.31 GB CPU-only) vs 3.75 GB. We keep Ollama for this entry (switching would cost
the first-run progress screen and its tests) and plan the switch after it.

**Linking:** for "I saw a tree losing its leaves and thought of my father, who died in March"
the page offers Dickinson, Barrett Browning and Millay ("Listen, children: / Your father is
dead."); for the Spanish version, Rosalía de Castro ("Moría el sol, y las marchitas hojas").

**Image and audio (official multimodal weights, 4-bit, same card):** an image described in
2.2 s ("cats, remote controls, pink couch", correct) and a Spanish voice clip transcribed in
1.5 s with one word wrong (*parte* for *padre*); 7.5 GB of 8 GB reserved, so it is not in the
default deployment.

**People:** *(to do: 2–3 tester sessions — did you finish, does it feel like yours, what got
in the way.)*

## 6. Limitations

- The syllable counter agrees exactly with expert scansion on 59% of ADSO lines (mean error
  0.48, biased low), so metre differences of a few points are within its error.
- Rhyme is checked on the last word only (consonant rhyme); assonance and internal rhyme
  are not scored.
- Scansion covers Spanish, English and Italian; German and French are not done; Romansh has
  no scansion. Italian counting agrees exactly with expert scansion on 79.5% of 10,001
  annotated endecasillabi (Dante, Petrarca; mean error 0.23); unmarked *sdruccioli* and
  dialefe are its main misses.
- Some proposals still mix languages (an English word in a Spanish poem).
- Seeded runs do not reproduce exactly on Ollama (4 of 7 Italian sonnets differed between
  two runs with the same seeds), so benchmark differences of a few points are noise.
- Italian rhyme-word suggestions leave out longer words whose stress the engine cannot be
  sure of, so fewer are offered than in Spanish or English.
- Ollama 0.40.0 on Windows 11 25H2 with Developer Mode cannot read models it pulls
  ("untrusted mount point"); there the no-Docker start fails with that message, and the
  Docker start works.
- The safety screen is small, synthetic and same-author; it says nothing about slang,
  irony or Swiss German dialect. PoesIA makes no therapeutic claim.

## 7. Reproducibility

- Hardware: RTX 3070 8 GB, Ryzen 9 5900X, Windows 11 + WSL2, Docker Desktop 29.8.
- Engine: `OomAngel/poesia` at the commit pinned in `src/Dockerfile` (`POESIA_REF`).
- Model: GGUF as in section 3; Ollama 0.34.4.
- Benchmark: `scripts/evaluate_adapter_mlflow.py --ollama-model <name> --samples 3 --seed 0`
  (or `--openai-compat` for any endpoint, as the page calls it) in the engine repository;
  server comparison: `reports/eval_2026-10/p2-server-comparison.json`; safety:
  `scripts/evaluate_safety_screen.py`.

## 8. Before and during the hackathon

The engine predates the hackathon: PoesIA's scansion, rhyme and generation loop were built
from July 2026 (first commit 2026-07-26) and are open source. Built during the hackathon
(1–16 Oct): this repository and its Docker deployment; the writing page; the safety screen
and its test set; Apertus integration (runtime, chat format, the system-message fix, the
OpenAI-compatible client); the Apertus evaluation; the guided page, rhyme-word suggestions
and Italian scansion view; first-run setup, the offline bundle and the no-Docker start; the
Italian linking set; and fixes found on the way (English rhyme keys, model selection,
offline NLTK, focus while typing). The engine repository's history shows the dates.

## 9. Next steps

German and French scansion and page languages; moving the model server to llama.cpp;
short phrase suggestions between words and whole lines; fine-tuning Apertus on
public-domain verse in the five languages, kept only if it beats plain Apertus on this
benchmark; the photo and spoken reflection on Apertus's own image and audio input, on a card
with room for it.

## License

Creative Commons Attribution 4.0 (CC-BY-4.0). All HackApertus projects are open-sourced.

## References

*(to do: from the engine repository's `docs/hack_apertus/refs.bib`, once validated.)*
