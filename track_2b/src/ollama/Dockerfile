# One-shot model setup: the Modelfile and script are baked in, so no bind mount is needed.
FROM ollama/ollama:0.34.4
COPY Modelfile init-model.sh /setup/
ENTRYPOINT ["/bin/sh", "/setup/init-model.sh"]
