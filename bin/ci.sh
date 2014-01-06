#!/bin/bash

source "$HOME/.rvm/scripts/rvm"
ruby_version=$(cat .ruby-version)
ruby_gemset=$(cat .ruby-gemset)
rvm use "$ruby_version@$ruby_gemset" --create

set -e

cat <<EOF > config/database.yml
test:
  adapter: postgresql
  encoding: unicode
  database: tahi_test_ci
  pool: 5
  username: tahi
  password:
  host: localhost
EOF

bundle install

export RAILS_SECRET_TOKEN='abc'
RAILS_ENV=test rake db:test:load

set +e

RAILS_ENV=test rake jasmine:ci
jasmine_result=$?

rspec spec --format=documentation
rspec_result=$?

if [ $jasmine_result != '0' -o $rspec_result != '0' ]; then
  exit 1;
fi
