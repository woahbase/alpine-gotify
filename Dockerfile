# syntax=docker/dockerfile:1
#
ARG IMAGEBASE=frommakefile
#
FROM ${IMAGEBASE}
#
ARG SRCARCH
ARG VERSION
ARG CLIARCH
ARG CLIVERSION
#
ENV \
    GOTIFY_HOME=/gotify \
    GOTIFY_CONFIG=/etc/gotify/config.yml \
    GOTIFY_DATA=/gotify/data \
    GOTIFY_SERVER_PORT=80
#
RUN set -ex \
    && apk add -Uu --no-cache \
        ca-certificates \
        curl \
        tzdata \
        unzip \
#
    && echo "Using server version: $SRCARCH $VERSION" \
    && curl \
        -o /tmp/gotify-${SRCARCH}.zip \
        -jSLN https://github.com/gotify/server/releases/download/v${VERSION}/gotify-${SRCARCH}.zip \
    && cd /usr/local/bin \
    && unzip /tmp/gotify-${SRCARCH}.zip \
    && mv gotify-${SRCARCH} gotify-server \
    && chmod 755 gotify-server \
#
    && echo "Using cli version: $CLIARCH $CLIVERSION" \
    && curl \
        -o /usr/local/bin/gotify \
        -jSLN https://github.com/gotify/cli/releases/download/v${CLIVERSION}/gotify-cli-${CLIARCH} \
    && chmod 755 gotify \
    && apk del --purge \
        curl \
        unzip \
    && rm -rf /var/cache/apk/* /tmp/*
#
COPY root/ /
#
VOLUME  ${GOTIFY_DATA}
# WORKDIR ${GOTIFY_HOME}
#
EXPOSE ${GOTIFY_SERVER_PORT}
#
HEALTHCHECK \
    --interval=2m \
    --retries=5 \
    --start-period=5m \
    --timeout=10s \
    CMD \
    wget -q -T '2' -O /dev/null ${HEALTHCHECK_URL:-"http://localhost:${GOTIFY_SERVER_PORT}/health"} || exit 1
#
ENTRYPOINT ["/init"]
