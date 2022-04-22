MAKEFLAGS += -r -R
GIT_COMMIT:=$(shell git rev-parse --short HEAD)
IMG ?= eml/nvidia-fabricmanager-builder:$(GIT_COMMIT)

all: docker-build docker-run

docker-build:
	docker buildx build --platform linux/amd64 . \
		--no-cache \
		-f Dockerfile -t ${IMG} \
		--build-arg VERSION="$(VERSION)"

docker-run:
	docker run --rm -it \
		-v $(pwd):/data \
		-w / \
		${IMG}

build: docker-build docker-run
	ls /RPMS/x86_64
	