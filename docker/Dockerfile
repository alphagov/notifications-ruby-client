FROM ruby:2.3.1-slim

RUN \
	echo "Install Debian packages" \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends \
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
