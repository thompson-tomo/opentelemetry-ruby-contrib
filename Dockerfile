FROM alpine:3.24.1@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b AS alpine

# Metadata
LABEL maintainer="open-telemetry/opentelemetry-ruby-contrib"

# User and Group for app isolation
ARG APP_UID=1000
ARG APP_USER=app
ARG APP_GID=1000
ARG APP_GROUP=app
ARG APP_DIR=/app

ENV SHELL=/bin/bash

ARG PACKAGES="\
    autoconf \
    automake \
    bash \
    curl \
    binutils \
    build-base \
    coreutils  \
    execline \
    findutils \
    git \
    grep \
    less \
    libffi-dev \
    libstdc++ \
    libtool \
    libxml2-dev \
    libxslt-dev \
    mariadb-dev \
    sqlite-dev \
    openssl \
    postgresql-dev \
    tzdata \
    util-linux \
    imagemagick \
    yaml-dev \
    "
# Install packages
RUN apk update && \
    apk upgrade && \
    apk add --no-cache ${PACKAGES}

ENV TMPDIR=/var/tmp

# Add custom app User and Group
RUN addgroup -S -g "${APP_GID}" "${APP_GROUP}" && \
    adduser -S -g "${APP_GROUP}" -u "${APP_UID}" "${APP_USER}"

COPY --chown="${APP_USER}:${APP_GROUP}" mise.toml /app/mise.toml

USER "${APP_USER}"

# Configure Bundler and PATH
ENV LANG=C.UTF-8 \
    GEM_HOME=/bundle \
    BUNDLE_JOBS=20 \
    BUNDLE_RETRY=3
ENV BUNDLE_PATH=$GEM_HOME
ENV BUNDLE_APP_CONFIG="${BUNDLE_PATH}" \
    BUNDLE_BIN="${BUNDLE_PATH}/bin" \
    BUNDLE_GEMFILE=Gemfile
ENV PATH="${APP_DIR}/bin:${BUNDLE_BIN}:/home/${APP_USER}/.local/bin:${PATH}"

RUN curl -fsSL https://mise.run | sh && \
    echo 'eval "$(mise activate bash)"' >> ${HOME}/.bashrc

WORKDIR "${APP_DIR}"

RUN mise trust "${APP_DIR}/mise.toml"
RUN mise install

WORKDIR "${APP_DIR}"

# Commands will be supplied via `docker-compose`
CMD []
