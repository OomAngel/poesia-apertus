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
explains each problem in plain language. A safety screen runs before any shaping. On a
seeded benchmark of 36 sonnets (18 Spanish, 18 English) Apertus behind the engine writes
82% (es) and 89% (en) of lines in exact metre, the best of the five setups we measured,
running on one 8 GB consumer GPU with no network.

## 2. Architecture

```
browser ──► PoesIA page (FastAPI, port 8000) ──► scansion engine (deterministic, in-process)
                    │                         ├─► safety screen (phrases + one model question)
                    └──── OpenAI-compatible API ──► Ollama ──► Apertus v1.5 8B text (GGUF Q4_K_M)
```

- **Page** (`poesia.webapp`): every line is a text field the author fills; each line is
  scanned as they type (`/api/scan`); proposals come from `/api/propose`, ranked by the
  scan, not by model likelihood, and shown greyed until used or edited. Each line records
  its origin (written / suggestion used / suggestion edited); "Keep" downloads the poem with
  the statement "N of M lines worded by the author". Drafts live in the browser tab only.
- **Engine** (`poesia` package, Spanish and English): metrical syllable count with
  synalepha and final-stress rules, stress pattern, rhyme key; explanations from
  `poesia.teaching`.
- **Model**: Apertus v1.5 8B text backbone, served by Ollama 0.34.4.

### Target architecture

**a) On-premise and b) air-gapped.** Everything runs on one machine, bound to
`127.0.0.1`. Build time needs the network: Python packages, NLTK data and the engine are
baked into the page image; the first `make run` downloads the model (~5 GB) into a Docker
volume. Runtime needs none: we ran the page image with `--network none` (scan, rhyme of an
out-of-dictionary word, safety screen all work) and the model from the volume.
*(to do: full `make run` with the host network disconnected, and on a CPU-only server.)*

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

*(to do: the row with the fragment filter, run 2026-10-07.)*

**Safety screen** (risk recall on 20, false alarms on 40 safe):

| | before tuning | after adding conjugated forms |
|---|---|---|
| phrase list | 11/20, 0/40 | 19/20, 0/40 |
| Apertus yes/no | 13/20, 0/40 | (not tuned) |
| either (the screen) | 18/20, 0/40 | 20/20, 0/40 |

The phrase list and the test set were written by the same hand, so the tuned numbers are
optimistic; the set is a regression test, not a validation.

**Speed:** a suggestion takes 1–5 s on the RTX 3070; a fully automatic sonnet (the benchmark)
~35 s. *(to do: CPU-only timing and watts per poem.)*

**People:** *(to do: 2–3 tester sessions — did you finish, does it feel like yours, what got
in the way.)*

## 6. Limitations

- The syllable counter agrees exactly with expert scansion on 59% of ADSO lines (mean error
  0.48, biased low), so metre differences of a few points are within its error.
- Rhyme is checked on the last word only (consonant rhyme); assonance and internal rhyme
  are not scored.
- Scansion covers Spanish and English; Italian, German and French are not done; Romansh has
  no scansion.
- Some proposals still mix languages (an English word in a Spanish poem).
- The safety screen is small, synthetic and same-author; it says nothing about slang,
  irony or Swiss German dialect. PoesIA makes no therapeutic claim.

## 7. Reproducibility

- Hardware: RTX 3070 8 GB, Ryzen 9 5900X, Windows 11 + WSL2, Docker Desktop 29.8.
- Engine: `OomAngel/poesia` at commit `c0037fb` (pinned in `src/Dockerfile`).
- Model: GGUF as in section 3; Ollama 0.34.4.
- Benchmark: `scripts/evaluate_adapter_mlflow.py --ollama-model <name> --samples 3 --seed 0`
  in the engine repository; safety: `scripts/evaluate_safety_screen.py`.

## 8. Before and during the hackathon

The engine predates the hackathon: PoesIA's scansion, rhyme and generation loop were built
from July 2026 (first commit 2026-07-26) and are open source. Built during the hackathon
(1–16 Oct): this repository and its Docker deployment; the writing page; the safety screen
and its test set; Apertus integration (runtime, chat format, the system-message fix, the
OpenAI-compatible client); the Apertus evaluation; and fixes found on the way (English
rhyme keys, model selection, offline NLTK). The engine repository's history shows the dates.

## 9. Next steps

Italian, German and French scansion; fine-tuning Apertus on public-domain verse in the five
languages, kept only if it beats plain Apertus on this benchmark; read-back with an offline
synthetic voice; linking each poem to public-domain poems on the same feeling.

## License

Creative Commons Attribution 4.0 (CC-BY-4.0). All HackApertus projects are open-sourced.

## References

*(to do: from the engine repository's `docs/hack_apertus/refs.bib`, once validated.)*
