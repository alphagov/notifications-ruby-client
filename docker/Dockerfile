FROM ruby:2.4-slim

ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG NO_PROXY

RUN \
	echo "Install Debian packages" \
	&& ([ -z "$HTTP_PROXY" ] || echo "Acquire::http::Proxy \"${HTTP_PROXY}\";" > /etc/apt/apt.conf.d/99HttpProxy) \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends \
		gcc \
		make \
		curl \
		git \

	&& echo "Clean up" \
	&& rm -rf /var/lib/apt/lists/* /tmp/*

ENV PATH=/var/project/vendor/bin:$PATH \
    BUNDLE_PATH="/var/project/vendor/bundle" \
    BUNDLE_BIN="/var/project/vendor/bin" \
    BUNDLE_APP_CONFIG="/var/project/.bundle"


WORKDIR /var/project
