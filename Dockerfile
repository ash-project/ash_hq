FROM hexpm/elixir:1.14.3-erlang-25.0-ubuntu-xenial-20210804
# install build dependencies
USER root
RUN apt-get update
RUN apt-get install -y wget
RUN wget https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb
RUN dpkg -i erlang-solutions_2.0_all.deb
RUN apt-get update
RUN apt-get install -y git
RUN apt-get install -y gcc
RUN apt-get install -y g++
RUN apt-get install -y make
RUN apt-get install -y curl
RUN apt-get install -y build-essential
RUN apt-get install -y esl-erlang
RUN apt-get install -y apt-transport-https
RUN apt-get install -y ca-certificates
RUN apt-get install -y gnupg
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
CMD ["_build/prod/rel/ash_hq/bin/ash_hq", "start"]
