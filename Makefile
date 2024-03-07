APP_NAME="ssedov/dirbackup-local"
TAG="dev"

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help
help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

build: ## Build the image
	docker buildx create --name multi-arch --driver docker-container --use
	docker buildx inspect --bootstrap
	docker buildx build --platform linux/amd64,linux/arm64 -t $(APP_NAME):$(TAG) --pull --push docker
	docker buildx rm multi-arch

shell: ## Creates a shell inside the container for debug purposes
	docker run -it $(APP_NAME):$(TAG) bash
