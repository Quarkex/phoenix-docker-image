  #################
 # phoenix 1.4.0 #
#################

FROM elixir:1.10.0
MAINTAINER Manlio García <quarkex@gmail.com>

RUN apt-get update  \
 && apt-get install \
 sudo               \
 locales            \
 git                \
 npm                \
 apt-utils          \
 nodejs             \
 build-essential    \
 inotify-tools      \
 postgresql-client  \
 -y                 \
 && curl -sL https://deb.nodesource.com/setup_13.x | bash

# Set the locale
RUN touch /usr/share/locale/locale.alias
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
   locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ENV APP_HOME /app
ENV APP_NAME sample_app
ENV TITLE sample_app
ENV DOMAIN localhost
ENV PORT 4000
ENV MIX_ENV "dev"

ENV PGPORT 5432
ENV PGHOST 172.17.0.1
ENV PGUSER postgres
ENV PGPASSWORD postgres
ENV PGDATABASE postgres

RUN groupadd -g 40759 elixir && useradd -u 40759 -g 40759 -m elixir

COPY sudoers /etc/sudoers.d/sudoers
COPY environment /etc/environment
COPY sanitize /usr/local/bin/sanitize
COPY entrypoint.sh /.

RUN chmod +x /usr/local/bin/sanitize && chmod 0440 /etc/sudoers.d/sudoers

WORKDIR $APP_HOME

EXPOSE 4000

USER elixir

RUN mix local.hex --force \
 && mix archive.install --force hex phx_new 1.4.12 \
 && mix local.rebar --force

CMD /entrypoint.sh
