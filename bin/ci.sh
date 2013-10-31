#!/bin/sh

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
