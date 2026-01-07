# syntax=docker/dockerfile:1
FROM elixir:1.19-alpine

ARG PHX_VERSION=''

ENV DATABASE_URL=''
ENV MIX_ENV=dev
ENV PORT=4000

RUN set -eux; \
	addgroup -g 935 -S phoenix; \
	adduser -u 935 -S -D -G phoenix -H -h /opt/phoenix -s /bin/ash phoenix; \
	install --verbose --directory --owner phoenix --group phoenix --mode 1755 /opt/phoenix

RUN apk add --no-cache \
    openssl \
    make \
    gcc \
    musl-dev \
    postgresql18-client \ 
    inotify-tools \
    git 

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]

USER phoenix

RUN git config --global init.defaultBranch main

RUN mix local.hex --force \
    && mix archive.install hex phx_new $PHX_VERSION --force \
    && mix local.rebar --force

EXPOSE 4000-4025

CMD ["mix", "phx.server"]
