# Linking index

Poems the page may offer after someone writes ("Poems that feel like this"), with their
vectors. Built by `scripts/build_linking_index.py` in [PoesIA](https://github.com/OomAngel/poesia)
from its corpus; up to 3,000 poems per language (Italian, German, French: all available), 4–24 lines
each, sampled with seed 0.

| Language | Licence | Poems |
|---|---|---|
| en | CC0 1.0 (DanFosing/public-domain-poetry) | 2640 |
| en | Public domain (Project Gutenberg) | 360 |
| es | CC BY 4.0 (DISCO v5.0) | 103 |
| es | CC BY 4.0 (DISCO) | 2039 |
| es | Public domain (Project Gutenberg) | 858 |
| it | Public domain (Project Gutenberg) | 609 |
| de | Public domain (Project Gutenberg) | 676 |
| fr | Public domain (Project Gutenberg) | 547 |

Only sources whose texts may be shown are included: Project Gutenberg books (public
domain), the `DanFosing/public-domain-poetry` set (CC0 1.0), and DISCO, the Diachronic
Spanish Sonnet Corpus (Ruiz Fabo, Martínez Cantón, Calvo Tello et al.; CC BY 4.0). Authors
known to have died after 1955 are excluded (life + 70 years).

Italian comes from fifteen Gutenberg books fetched for this index only (PoesIA
`scripts/fetch_gutenberg_poems.py --linking-only`; not used for training), with front
matter, contents lines and the speakers of dramatic passages removed: Ada Negri 202, Amalia
Guglielminetti 155, Gabriele D'Annunzio 107, Emilio De Marchi 61, Annie Vivanti 32, Luigi
Gualdo 28, Giacomo Leopardi 10, Vittorio Betteloni 10, Giuseppe Montanelli 3, Mario
Rapisardi 1.

German and French were added on 2026-10-09 the same way, from Gutenberg books fetched for
this index only (authors who died by 1955): German Rainer Maria Rilke 286, Heinrich Heine 204, Johann Wolfgang von Goethe 122, Georg Trakl 64; French Paul Verlaine 149, José-Maria de Heredia 112, Victor Hugo 86, Charles Baudelaire 75, Arthur Rimbaud 54, Anna de Noailles 40, Théophile Gautier 17, Marceline Desbordes-Valmore 14.
Adding them left the Spanish, English and Italian files byte for byte as they were (one
seeded shuffle runs through the languages in order; the new ones come last).

Each poem carries its author, source and licence; the page shows them with the poem.

Vectors: `bge-m3` (BAAI, MIT) embeddings of title + first eight lines, unit length, float16.
