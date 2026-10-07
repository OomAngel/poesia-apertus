# PoesIA writing page (poesia.webapp) with the Spanish, English and Italian scansion engines.

# Build stage: wheels only. git and g++ (editdistance, via g2p_en, has no wheel for
# Python 3.13) never reach the final image.
FROM python:3.13-slim AS build
# The engine: OomAngel/poesia (MIT), pinned to the commit this entry was tested with.
ARG POESIA_REF=352ca8beaff35fb6c5a182b6fa5472fe28af613f
RUN apt-get update \
 && apt-get install -y --no-install-recommends git g++ \
 && rm -rf /var/lib/apt/lists/*
# english-scan, not english: the latter adds prosodic (planned, unused) and ~450 MB with it.
RUN pip wheel --no-cache-dir --wheel-dir /wheels \
    "poesia[web,spanish,english-scan,recitation] @ git+https://github.com/OomAngel/poesia@${POESIA_REF}"

FROM python:3.13-slim
# The wheels are mounted for the install, not copied: a copied-then-deleted layer still ships.
RUN --mount=type=bind,from=build,source=/wheels,target=/wheels \
    pip install --no-cache-dir --no-index --find-links /wheels \
    "poesia[web,spanish,english-scan,recitation]"

# Bake everything the scanners fetch on first use, so the container needs no network:
# NLTK data for g2p_en (English words CMUdict lacks), and one scan per language.
ENV NLTK_DATA=/usr/share/nltk_data
RUN python -c "import nltk; [nltk.download(p, download_dir='/usr/share/nltk_data', quiet=True) for p in ('averaged_perceptron_tagger_eng', 'cmudict')]" \
 && python -c "from poesia.webapp import scan_line; print(scan_line('La luna vierte su silencio blanco', 'es', 'soneto', 0, [])['syllables'], scan_line('The restless sea in endless rhythm rolls', 'en', 'sonnet_shakespearean', 0, [])['syllables'])"

# Read-back voices (Piper, offline), from rhasspy/piper-voices at a fixed revision:
# es_ES-davefx-medium (CC0), en_US-ljspeech-medium (public domain), it_IT-serena-medium (CC BY 4.0).
ARG VOICES_REV=c10ece1aade47bb51c153c893d14e5bf8e5b7117
ENV POESIA_PIPER_VOICES=/opt/piper
RUN python - <<'PY'
import os, urllib.request
rev = os.environ["VOICES_REV"]  # build ARGs are visible to RUN as environment variables
for rel in ("es/es_ES/davefx/medium/es_ES-davefx-medium.onnx",
            "en/en_US/ljspeech/medium/en_US-ljspeech-medium.onnx",
            "it/it_IT/serena/medium/it_IT-serena-medium.onnx"):
    for suffix in ("", ".json"):
        dest = f"/opt/piper/{rel}{suffix}"
        os.makedirs(os.path.dirname(dest), exist_ok=True)
        url = f"https://huggingface.co/rhasspy/piper-voices/resolve/{rev}/{rel}{suffix}"
        urllib.request.urlretrieve(url, dest)
PY
RUN python -c "from poesia.webapp import read_aloud; print([len(read_aloud(t, l)) for t, l in (('Prueba', 'es'), ('Test', 'en'), ('Prova', 'it'))])"

# Linking index: public-domain / openly licensed poems and their bge-m3 vectors (data/linking).
COPY data/linking /opt/linking
ENV POESIA_LINK_INDEX=/opt/linking

RUN useradd --create-home poet
USER poet
ENV POESIA_WEB_HOST=0.0.0.0 POESIA_WEB_PORT=8000
EXPOSE 8000
CMD ["poesia-web"]
