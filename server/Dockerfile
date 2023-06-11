FROM elixir:1.13.4

WORKDIR /app
COPY . ./

RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get
RUN mix do compile

EXPOSE 4000

ENTRYPOINT ["mix", "phx.server"]