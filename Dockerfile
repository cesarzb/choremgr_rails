FROM ruby:3.2.2

RUN apt-get update && \
  apt-get install -y \
  build-essential \
  postgresql-client \
  libpq-dev \
  nodejs \
  yarn

WORKDIR /app

COPY . . 

RUN bundle install

CMD bundle exec rails s -p 3000 -b '0.0.0.0'
