FROM ruby:2.6-slim

RUN \
	echo "Install Debian packages" \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends \
		gcc \
		make \
		curl \
		git \
    gnupg

WORKDIR /var/project
