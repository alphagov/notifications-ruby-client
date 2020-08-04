.DEFAULT_GOAL := help
SHELL := /bin/bash

DOCKER_BUILDER_IMAGE_NAME = govuk/notify-ruby-client-builder

BUILD_TAG ?= notifications-ruby-client-manual

DOCKER_CONTAINER_PREFIX = ${USER}-${BUILD_TAG}

.PHONY: help
help:
	@cat $(MAKEFILE_LIST) | grep -E '^[a-zA-Z_-]+:.*?## .*$$' | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: dependencies
dependencies: ## Install build dependencies
	bundle install --path=vendor/bundle --binstubs=vendor/bin

.PHONY: build
build: dependencies ## Build project

.PHONY: test
test: ## Run tests
	bundle exec rake spec

.PHONY: integration-test
integration-test: ## Run integration tests
	bundle exec bin/test_client.rb

.PHONY: generate-env-file
generate-env-file: ## Generate the environment file for running the tests inside a Docker container
	bin/generate_docker_env.sh

.PHONY: prepare-docker-runner-image
prepare-docker-runner-image: ## Prepare the Docker builder image
	docker pull `grep "FROM " Dockerfile | cut -d ' ' -f 2` || true
	docker build -t ${DOCKER_BUILDER_IMAGE_NAME} .

.PHONY: build-with-docker
build-with-docker: prepare-docker-runner-image ## Build inside a Docker container
	docker run -i --rm \
		--name "${DOCKER_CONTAINER_PREFIX}-build" \
		-v "`pwd`:/var/project" \
		${DOCKER_BUILDER_IMAGE_NAME} \
		make build

.PHONY: test-with-docker
test-with-docker: prepare-docker-runner-image generate-env-file ## Run tests inside a Docker container
	docker run -i --rm \
		--name "${DOCKER_CONTAINER_PREFIX}-test" \
		-v "`pwd`:/var/project" \
		--env-file docker.env \
		${DOCKER_BUILDER_IMAGE_NAME} \
		make build test

.PHONY: integration-test-with-docker
integration-test-with-docker: prepare-docker-runner-image generate-env-file ## Run integration tests inside a Docker container
	docker run -i --rm \
		--name "${DOCKER_CONTAINER_PREFIX}-integration-test" \
		-v "`pwd`:/var/project" \
		--env-file docker.env \
		${DOCKER_BUILDER_IMAGE_NAME} \
		make build integration-test

.PHONY: get-client-version
get-client-version: ## Retrieve client version number from source code
	@ruby -e "require './lib/notifications/client/version'; puts Notifications::Client::VERSION"

.PHONY: publish-to-rubygems
publish-to-rubygems: ## Create gemspec file and publish to rubygems
	$(if ${GEM_HOST_API_KEY},,$(error Must specify GEM_HOST_API_KEY))
	gem build notifications-ruby-client.gemspec --output=release.gem
	gem push release.gem

.PHONY: clean-docker-containers
clean-docker-containers: ## Clean up any remaining docker containers
	docker rm -f $(shell docker ps -q -f "name=${DOCKER_CONTAINER_PREFIX}") 2> /dev/null || true

clean:
	rm -rf vendor
