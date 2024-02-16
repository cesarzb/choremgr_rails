FROM ruby:3.2.2

RUN apt-get update && \
  apt-get install -y \
  build-essential \
  postgresql-client \
  libpq-dev \
  nodejs \
  yarn \
  vim

WORKDIR /app

COPY . .

RUN bundle install
