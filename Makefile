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
	make -C docker build

.PHONY: build-with-docker
build-with-docker: prepare-docker-runner-image ## Build inside a Docker container
	docker run -i --rm \
		--name "${DOCKER_CONTAINER_PREFIX}-build" \
		-v "`pwd`:/var/project" \
		-e http_proxy="${HTTP_PROXY}" \
		-e HTTP_PROXY="${HTTP_PROXY}" \
		-e https_proxy="${HTTPS_PROXY}" \
		-e HTTPS_PROXY="${HTTPS_PROXY}" \
		-e NO_PROXY="${NO_PROXY}" \
		${DOCKER_BUILDER_IMAGE_NAME} \
		make build

.PHONY: test-with-docker
test-with-docker: prepare-docker-runner-image generate-env-file ## Run tests inside a Docker container
	docker run -i --rm \
		--name "${DOCKER_CONTAINER_PREFIX}-test" \
		-v "`pwd`:/var/project" \
		-e http_proxy="${HTTP_PROXY}" \
		-e HTTP_PROXY="${HTTP_PROXY}" \
		-e https_proxy="${HTTPS_PROXY}" \
		-e HTTPS_PROXY="${HTTPS_PROXY}" \
		-e NO_PROXY="${NO_PROXY}" \
		--env-file docker.env \
		${DOCKER_BUILDER_IMAGE_NAME} \
		make test

.PHONY: integration-test-with-docker
integration-test-with-docker: prepare-docker-runner-image generate-env-file ## Run integration tests inside a Docker container
	docker run -i --rm \
		--name "${DOCKER_CONTAINER_PREFIX}-integration-test" \
		-v "`pwd`:/var/project" \
		-e http_proxy="${HTTP_PROXY}" \
		-e HTTP_PROXY="${HTTP_PROXY}" \
		-e https_proxy="${HTTPS_PROXY}" \
		-e HTTPS_PROXY="${HTTPS_PROXY}" \
		-e NO_PROXY="${NO_PROXY}" \
		--env-file docker.env \
		${DOCKER_BUILDER_IMAGE_NAME} \
		make integration-test


.PHONY: publish-to-rubygems
publish-to-rubygems:
	$(if ${GEM_HOST_API_KEY},,$(error Must specify GEM_HOST_API_KEY))
	gem build notifications-ruby-client.gemspec --output=release.gem
	gem push release.gem

.PHONY: clean-docker-containers
clean-docker-containers: ## Clean up any remaining docker containers
	docker rm -f $(shell docker ps -q -f "name=${DOCKER_CONTAINER_PREFIX}") 2> /dev/null || true

.PHONY: run-govuk-lint
run-govuk-lint: ## Runs GOVUK-lint for Ruby
	bundle exec govuk-lint-ruby lib spec bin/test_client

clean:
	rm -rf vendor
