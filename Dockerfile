# https://hub.docker.com/_/ruby
FROM ruby:2.6.0

LABEL maintainer="<mehera.p@gmail.com>"

RUN set -ex; \
    apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    rsync \
    curl
WORKDIR apitest/
COPY Gemfile* /apitest/
RUN bundle install
ADD . /apitest/
