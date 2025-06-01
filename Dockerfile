FROM hexpm/elixir:1.18.3-erlang-27.3.4-ubuntu-noble-20250415.1

# install build dependencies
USER root
RUN apt-get update
RUN apt-get install -y wget
RUN apt-get install -y gnupg
RUN apt-get update
RUN apt-get install -y git
RUN apt-get install -y gcc
RUN apt-get install -y g++
RUN apt-get install -y make
RUN apt-get install -y curl
RUN apt-get install -y build-essential
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get install -y apt-transport-https
RUN apt-get install -y ca-certificates
RUN apt-get install -y fuse3 libfuse3-dev libglib2.0-dev

COPY --from=flyio/litefs:0.5 /usr/local/bin/litefs /usr/local/bin/litefs

# Install Node.js using the official NodeSource setup script
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
RUN apt-get install -y nodejs

RUN npm install --global yarn

RUN mix local.hex --force && \
    mix local.rebar --force

ENV MIX_ENV=prod

COPY ./assets/package.json assets/package.json
COPY ./assets/package-lock.json assets/package-lock.json
RUN npm install --prefix ./assets

COPY ./mix.exs .
COPY ./mix.lock .
COPY ./config/config.exs config/config.exs
COPY ./config/prod.exs config/prod.exs
RUN mix deps.get
RUN mix deps.compile

COPY ./lib ./lib
COPY ./priv ./priv
COPY ./assets ./assets
RUN mix assets.deploy
RUN mix compile

COPY ./config/runtime.exs config/runtime.exs
COPY ./rel ./rel
RUN mix release --overwrite

RUN mkdir indexes
COPY ./litefs.yml ./litefs.yml

CMD ["_build/prod/rel/ash_hq/bin/ash_hq", "start"]
