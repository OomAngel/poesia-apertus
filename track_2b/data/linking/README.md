# Linking index

Poems the page may offer after someone writes ("Poems that feel like this"), with their
vectors. Built by `scripts/build_linking_index.py` in [PoesIA](https://github.com/OomAngel/poesia)
from its corpus; 3,000 poems per language, 4–24 lines each, sampled with seed 0.

| Language | Licence | Poems |
|---|---|---|
| en | CC0 1.0 (DanFosing/public-domain-poetry) | 2640 |
| en | Public domain (Project Gutenberg) | 360 |
| es | CC BY 4.0 (DISCO v5.0) | 103 |
| es | CC BY 4.0 (DISCO) | 2039 |
| es | Public domain (Project Gutenberg) | 858 |

Only sources whose texts may be shown are included: Project Gutenberg books (public
domain), the `DanFosing/public-domain-poetry` set (CC0 1.0), and DISCO, the Diachronic
Spanish Sonnet Corpus (Ruiz Fabo, Martínez Cantón, Calvo Tello et al.; CC BY 4.0). Authors
known to have died after 1955 are excluded (life + 70 years). Each poem carries its author,
source and licence; the page shows them with the poem.

Vectors: `bge-m3` (BAAI, MIT) embeddings of title + first eight lines, unit length, float16.
