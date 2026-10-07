.PHONY: run stop clean bundle load

# Docker CLI; on WSL without Docker Desktop's WSL integration, set DOCKER=docker.exe.
DOCKER ?= docker

# Starts the model and the page (GPU when available); open http://localhost:8000.
# Same as ./run.sh (Linux, macOS, WSL) or .\run.ps1 (Windows PowerShell).
run:
	DOCKER="$(DOCKER)" ./run.sh

stop:
	$(DOCKER) compose -f docker-compose.yml -f docker-compose.gpu.yml down

# Also removes the downloaded models (the next run downloads them again).
clean:
	$(DOCKER) compose -f docker-compose.yml down --volumes

# For a machine without network: pack images + prepared models into poesia-bundle/ (~10 GB);
# there, `make load` then `./run.sh --offline`.
bundle:
	DOCKER="$(DOCKER)" ./bundle.sh

load:
	DOCKER="$(DOCKER)" ./load.sh poesia-bundle
