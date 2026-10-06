# PoesIA writing page (poesia.webapp) with the Spanish and English scansion engines.
FROM python:3.13-slim

# The engine: OomAngel/poesia (MIT), pinned to the commit this entry was tested with.
# g++ only to build editdistance (g2p_en), which has no wheel for Python 3.13; removed after.
ARG POESIA_REF=c0037fbfcfe0a5e14a4d1209228b3b5d38b9198c
RUN apt-get update \
 && apt-get install -y --no-install-recommends git g++ \
 && rm -rf /var/lib/apt/lists/* \
 && pip install --no-cache-dir "poesia[web,spanish,english] @ git+https://github.com/OomAngel/poesia@${POESIA_REF}" \
 && apt-get purge -y git g++ && apt-get autoremove -y

# Bake everything the scanners fetch on first use, so the container needs no network:
# NLTK data for g2p_en (English words CMUdict lacks), and one scan per language.
ENV NLTK_DATA=/usr/share/nltk_data
RUN python -c "import nltk; [nltk.download(p, download_dir='/usr/share/nltk_data', quiet=True) for p in ('averaged_perceptron_tagger_eng', 'cmudict')]" \
 && python -c "from poesia.webapp import scan_line; print(scan_line('La luna vierte su silencio blanco', 'es', 'soneto', 0, [])['syllables'], scan_line('The restless sea in endless rhythm rolls', 'en', 'sonnet_shakespearean', 0, [])['syllables'])"

RUN useradd --create-home poet
USER poet
ENV POESIA_WEB_HOST=0.0.0.0 POESIA_WEB_PORT=8000
EXPOSE 8000
CMD ["poesia-web"]
