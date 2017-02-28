PROJECT := rgon-proxy
PLATFORM := linux
ARCH := amd64
DOCKER_IMAGE := causticlab/$(PROJECT)

VERSION := $(shell cat VERSION)
GITSHA := $(shell git rev-parse --short HEAD)

all: help

help:
	@echo "make image - build release image"
	@echo "make run - start the docker container"
	@echo "make release - tag with version and trigger CI release build"
	@echo "make dockerhub - build and push image to Docker Hub"
	@echo "make version - show app version"

image:
	docker build -t $(DOCKER_IMAGE):$(VERSION) -f Dockerfile .

run:
	docker run -td --name $(PROJECT) $(DOCKER_IMAGE):$(VERSION)

bash:
	docker exec -it $(PROJECT) bash

clean-docker:
	docker stop $(PROJECT) && docker rm $(PROJECT)

release:
	git tag `cat VERSION`
	git push origin master --tags

dockerhub: image
	@echo "Pushing $(DOCKER_IMAGE):$(VERSION)"
	docker push $(DOCKER_IMAGE):$(VERSION)

version:
	@echo $(VERSION) $(GITSHA)