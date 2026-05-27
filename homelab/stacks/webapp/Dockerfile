FROM ruby:3.3-slim

RUN apt-get update && apt-get install -y \
  build-essential \
  libpq-dev \
  nodejs \
  npm \
  git \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install --without development test

COPY . .

RUN bundle exec rails assets:precompile

EXPOSE 3000
