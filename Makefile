APP_NAME="ssedov/dirbackup-local"
TAG ?= latest

# HELP
# This will output the help for each task
.PHONY: help
help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

build: ## Build the container image with tag (e.g. make build TAG=latest)
	@docker buildx create --name multi-arch --driver docker-container --use
	@docker buildx inspect --bootstrap
	@docker buildx build --platform linux/amd64,linux/arm64 -t $(APP_NAME):$(TAG) --pull --push .
	@docker buildx rm multi-arch

build-latest: TAG=latest
build-latest: build ## Build the image with the 'latest' tag

build-dev: TAG=dev 
build-dev: build ## Build the image with the 'dev' tag

shell: ## Creates a shell inside the container for debug purposes
	@docker run -it $(APP_NAME):$(TAG) bash
