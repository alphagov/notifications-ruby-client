.DEFAULT_GOAL := help
SHELL := /bin/bash

.PHONY: help
help:
	@cat $(MAKEFILE_LIST) | grep -E '^[a-zA-Z_-]+:.*?## .*$$' | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: bootstrap
bootstrap: ## Install build dependencies
	bundle install

.PHONY: build
build: bootstrap ## Build project (dummy task for CI)

.PHONY: test
test: ## Run tests
	bundle exec rake spec

.PHONY: integration-test
integration-test: ## Run integration tests
	bundle exec bin/test_client.rb

.PHONY: bootstrap-with-docker
bootstrap-with-docker: ## Prepare the Docker builder image
	docker build -t notifications-ruby-client .

.PHONY: test-with-docker
test-with-docker: ## Run tests inside a Docker container
	./scripts/run_with_docker.sh make test

.PHONY: integration-test-with-docker
integration-test-with-docker: ## Run integration tests inside a Docker container
	./scripts/run_with_docker.sh make integration-test

.PHONY: get-client-version
get-client-version: ## Retrieve client version number from source code
	@ruby -e "require './lib/notifications/client/version'; puts Notifications::Client::VERSION"

.PHONY: publish-to-rubygems
publish-to-rubygems: ## Create gemspec file and publish to rubygems
	$(if ${GEM_HOST_API_KEY},,$(error Must specify GEM_HOST_API_KEY))
	gem build notifications-ruby-client.gemspec --output=release.gem
	gem push release.gem

clean:
	rm -rf vendor
