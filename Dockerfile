FROM hexpm/elixir:1.15.4-erlang-26.0.2-ubuntu-focal-20230126
# install build dependencies
USER root
RUN apt-get update
RUN apt-get install -y wget
RUN apt-get install -y gnupg
RUN wget https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb
RUN dpkg -i erlang-solutions_2.0_all.deb
RUN apt-get update
RUN apt-get install -y git
RUN apt-get install -y gcc
RUN apt-get install -y g++
RUN apt-get install -y make
RUN apt-get install -y curl
RUN apt-get install -y build-essential
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get install -y esl-erlang
RUN apt-get install -y apt-transport-https
RUN apt-get install -y ca-certificates
RUN apt-get install -y fuse3 libfuse3-dev libglib2.0-dev
RUN apt-get install -y sqlite3
COPY --from=flyio/litefs:0.5 /usr/local/bin/litefs /usr/local/bin/litefs
ENV NODE_MAJOR=16
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
RUN apt-get update
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
COPY ./assets/tailwind.colors.json ./assets/tailwind.colors.json
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
ENTRYPOINT litefs mount
