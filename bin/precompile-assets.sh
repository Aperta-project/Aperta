#!/bin/sh

git rm -rf public/assets/application-*
RAILS_ENV=production rake assets:precompile
