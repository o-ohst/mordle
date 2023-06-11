FROM elixir:1.13.4

WORKDIR /app
COPY . ./

ARG CLIENT_HOSTNAME
ARG SECRET_KEY_BASE
ARG PORT
ENV CLIENT_HOSTNAME=$CLIENT_HOSTNAME
ENV SECRET_KEY_BASE=$SECRET_KEY_BASE
ENV PORT=$PORT
ENV PHX_SERVER true
ENV MIX_ENV prod

RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get --only prod

RUN mix compile

EXPOSE 4000

ENTRYPOINT ["mix", "phx.server"]