#!/bin/bash

source "$HOME/.rvm/scripts/rvm"
rvm use "2.0.0-p247@tahi" --create

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
