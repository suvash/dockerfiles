.DEFAULT_GOAL:=build
SHELL:=/usr/bin/env bash

DOCKER_REPOSITORY=docker.io
REPO_USERNAME=suvash

IMAGE_PREFIX:=$(DOCKER_REPOSITORY)/$(REPO_USERNAME)

SHA_HEAD:=$(shell git rev-parse --short HEAD)
DATE_NOW:=$(shell date +%Y-%m-%dT%H:%M:%S%z)

PYTORCH_CUDA_NAME:=pytorch
PYTORCH_CUDA_TAG:=1.9.0-py3.7-cuda11.1-ubuntu20.04
PYTORCH_CUDA_FOLDER:=$(PYTORCH_CUDA_NAME)/$(PYTORCH_CUDA_TAG)
PYTORCH_CUDA_IMAGE:=$(IMAGE_PREFIX)/$(PYTORCH_CUDA_NAME):$(PYTORCH_CUDA_TAG)

# Build section

.PHONY: build build-pytorch-cuda

build: build-pytorch-cuda

build-pytorch-cuda:
	$(info -- Building docker image $(PYTORCH_CUDA_IMAGE))
	docker image build -t $(PYTORCH_CUDA_IMAGE) -f $(PYTORCH_CUDA_FOLDER)/Dockerfile $(PYTORCH_CUDA_FOLDER)

# Clean section

.PHONY: clean clean-pytorch-cuda

clean: clean-pytorch-cuda

clean-pytorch-cuda:
	$(info -- Cleaning docker image $(PYTORCH_CUDA_IMAGE))
	docker image rm $(PYTORCH_CUDA_IMAGE)
