# PoesIA writing page (poesia.webapp) with the Spanish and English scansion engines.
FROM python:3.13-slim

# The engine: OomAngel/poesia (MIT), pinned to the commit this entry was tested with.
# g++ only to build editdistance (g2p_en), which has no wheel for Python 3.13; removed after.
ARG POESIA_REF=6afa9fb46dd65b67f9d454394630456e4474bcda
RUN apt-get update \
 && apt-get install -y --no-install-recommends git g++ \
 && rm -rf /var/lib/apt/lists/* \
 && pip install --no-cache-dir "poesia[web,spanish,english,recitation] @ git+https://github.com/OomAngel/poesia@${POESIA_REF}" \
 && apt-get purge -y git g++ && apt-get autoremove -y

# Bake everything the scanners fetch on first use, so the container needs no network:
# NLTK data for g2p_en (English words CMUdict lacks), and one scan per language.
ENV NLTK_DATA=/usr/share/nltk_data
RUN python -c "import nltk; [nltk.download(p, download_dir='/usr/share/nltk_data', quiet=True) for p in ('averaged_perceptron_tagger_eng', 'cmudict')]" \
 && python -c "from poesia.webapp import scan_line; print(scan_line('La luna vierte su silencio blanco', 'es', 'soneto', 0, [])['syllables'], scan_line('The restless sea in endless rhythm rolls', 'en', 'sonnet_shakespearean', 0, [])['syllables'])"

# Read-back voices (Piper, offline), from rhasspy/piper-voices at a fixed revision:
# es_ES-davefx-medium (CC0) and en_US-ljspeech-medium (public domain).
ARG VOICES_REV=c10ece1aade47bb51c153c893d14e5bf8e5b7117
ENV POESIA_PIPER_VOICES=/opt/piper
RUN python - <<'PY'
import os, urllib.request
rev = os.environ["VOICES_REV"]  # build ARGs are visible to RUN as environment variables
for rel in ("es/es_ES/davefx/medium/es_ES-davefx-medium.onnx",
            "en/en_US/ljspeech/medium/en_US-ljspeech-medium.onnx"):
    for suffix in ("", ".json"):
        dest = f"/opt/piper/{rel}{suffix}"
        os.makedirs(os.path.dirname(dest), exist_ok=True)
        url = f"https://huggingface.co/rhasspy/piper-voices/resolve/{rev}/{rel}{suffix}"
        urllib.request.urlretrieve(url, dest)
PY
RUN python -c "from poesia.webapp import read_aloud; print(len(read_aloud('Prueba', 'es')), len(read_aloud('Test', 'en')))"

RUN useradd --create-home poet
USER poet
ENV POESIA_WEB_HOST=0.0.0.0 POESIA_WEB_PORT=8000
EXPOSE 8000
CMD ["poesia-web"]
