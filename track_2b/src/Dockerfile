# PoesIA writing page (poesia.webapp) with the Spanish, English and Italian scansion engines.

FROM python:3.13-slim
# The engine: OomAngel/poesia (MIT), pinned to the commit this entry was tested with. Every
# dependency has a wheel or is pure Python (checked 2026-10-07 with the compiler disabled),
# and the archive URL needs no git, so the image needs no build tools at all.
ARG POESIA_REF=2724de915c2de20b8eda198bead7b07446ed2fe6
# english-scan, not english: the latter adds prosodic (planned, unused) and ~450 MB with it.
RUN pip install --no-cache-dir \
    "poesia[web,spanish,english-scan,recitation] @ https://github.com/OomAngel/poesia/archive/${POESIA_REF}.zip"

# Bake everything the scanners fetch on first use, so the container needs no network:
# NLTK data for g2p_en (English words CMUdict lacks), and one scan per language.
ENV NLTK_DATA=/usr/share/nltk_data
RUN python -c "import nltk; [nltk.download(p, download_dir='/usr/share/nltk_data', quiet=True) for p in ('averaged_perceptron_tagger_eng', 'cmudict')]" \
 && python -c "from poesia.webapp import scan_line; print(scan_line('La luna vierte su silencio blanco', 'es', 'soneto', 0, [])['syllables'], scan_line('The restless sea in endless rhythm rolls', 'en', 'sonnet_shakespearean', 0, [])['syllables'], scan_line('Die Nacht ist still, der Mond geht leise auf', 'de', 'sonett', 0, [])['syllables'], scan_line('Le soir descend sur la ville endormie', 'fr', 'sonnet', 0, [])['syllables'])"

# The page's line proposals go through the engine's loop (scorer, memoria): run one with a stub
# model, so a missing dependency fails the build, not the page (PyYAML did, 2026-10-13).
RUN python -c "from poesia.generation.llm_client import StubLLMClient; from poesia.webapp import propose_lines; print(len(propose_lines(StubLLMClient(), 'es', 'soneto', 2, ['Quizá ahora me cuides desde el cielo', 'como la luz que pasa entre las ramas', '', ''], 'padre', '', 3)), 'proposals')"

# Read-back voices (Piper, offline), from rhasspy/piper-voices at the revision poesia.voices
# pins: es_ES-davefx-medium (CC0), en_US-ljspeech-medium (public domain), it_IT-serena-medium
# (CC BY 4.0), de_DE-thorsten-medium (CC0), fr_FR-siwis-medium (CC BY 4.0).
ENV POESIA_PIPER_VOICES=/opt/piper
RUN python -m poesia.voices /opt/piper
RUN python -c "from poesia.webapp import read_aloud; print([len(read_aloud(t, l)) for t, l in (('Prueba', 'es'), ('Test', 'en'), ('Prova', 'it'), ('Probe', 'de'), ('Essai', 'fr'))])"

# Linking index: public-domain / openly licensed poems and their bge-m3 vectors (data/linking).
COPY data/linking /opt/linking
ENV POESIA_LINK_INDEX=/opt/linking

RUN useradd --create-home poet
USER poet
ENV POESIA_WEB_HOST=0.0.0.0 POESIA_WEB_PORT=8000
EXPOSE 8000
CMD ["poesia-web"]
