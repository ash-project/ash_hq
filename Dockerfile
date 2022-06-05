FROM hexpm/elixir:1.13.4-erlang-25.0-ubuntu-xenial-20210804
# install build dependencies
USER root
RUN apt-get update
RUN apt-get install -y git gcc g++ make curl 
RUN apt-get install -y build-essential
RUN curl -sL https://deb.nodesource.com/setup_16.x  | bash -
RUN curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update
RUN apt-get install -y nodejs yarn
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
RUN mix deps.get && \
  mix deps.compile
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
