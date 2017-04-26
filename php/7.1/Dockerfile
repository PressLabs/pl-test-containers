FROM php:7.1-alpine

RUN set -ex \
    && apk add --no-cache \
        bash \
        make \
        subversion \
        git \
        openssl \
    && docker-php-ext-install -j$(getconf _NPROCESSORS_ONLN) mysqli \
    && curl -L https://github.com/jwilder/dockerize/releases/download/v0.4.0/dockerize-alpine-linux-amd64-v0.4.0.tar.gz | tar -zxf - -C /usr/bin \
    && chown root:root /usr/bin/dockerize