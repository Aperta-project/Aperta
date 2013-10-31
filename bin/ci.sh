#!/bin/bash

source "$HOME/.rvm/scripts/rvm"
rvm use "2.0.0-p247@tahi"

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

rspec spec --format=documentation
