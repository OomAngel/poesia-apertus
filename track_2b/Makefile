.PHONY: run stop clean

# Docker CLI; on WSL without Docker Desktop's WSL integration, set DOCKER=docker.exe.
DOCKER ?= docker

# Local model unless LLM_BASE_URL points at another endpoint (judges' Apertus server).
PROFILE := $(if $(LLM_BASE_URL),,--profile local)
GPU := $(if $(shell $(DOCKER) info --format '{{json .Runtimes}}' 2>/dev/null | grep nvidia),-f docker-compose.gpu.yml,)

# Starts the model and the page; open http://localhost:8000 . First run downloads ~5 GB.
run:
	$(DOCKER) compose -f docker-compose.yml $(GPU) $(PROFILE) up --build

stop:
	$(DOCKER) compose -f docker-compose.yml $(GPU) --profile local down

# Also removes the downloaded model (the next run downloads it again).
clean:
	$(DOCKER) compose -f docker-compose.yml --profile local down --volumes
