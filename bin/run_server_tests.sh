#! /usr/bin/env bash

set -ex

# Install Rails pre-requisites
apt-get update
apt install -y --no-install-recommends postgresql-11 postgresql-client-11 libsodium-dev
bundle install

# Set up test environment
mkdir -p log
cp config/bitbucket/database.yml config/
cp config/bitbucket/sunspot.yml config/
cp config/bitbucket/mailers.yml config/

export RAILS_ENV=test
export DEVISE_JWT_SECRET_KEY=DEVISE_JWT_SECRET_KEY
export DEVISE_SECRET_KEY=DEVISE_SECRET_KEY

# Create the database
bundle exec rails db:drop
bundle exec rails db:create
bundle exec rails db:migrate

# Run tests
bundle exec rspec spec
