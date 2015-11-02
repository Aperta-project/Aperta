source 'https://rubygems.org'

# Remember to also change circle.yml and .ruby-version when the ruby version changes
ruby '2.2.3'

# Task Engines
gem 'plos_billing', path: 'engines/plos_billing'
gem 'plos_bio_internal_review', git: 'https://ea548e3d06f18f2c5287468e46ae5fe262d3f5ac:x-oauth-basic@github.com/tahi-project/plos_bio_internal_review'
gem 'plos_bio_tech_check', path: 'engines/plos_bio_tech_check'
gem 'tahi_standard_tasks', path: 'engines/tahi_standard_tasks'
gem 'tahi_upload_manuscript', path: 'engines/tahi_upload_manuscript'
gem 'tahi-assign_team', git: 'https://ea548e3d06f18f2c5287468e46ae5fe262d3f5ac:x-oauth-basic@github.com/tahi-project/tahi-assign_team'

# Gems
gem 'aasm', '~> 4.1.0'
gem 'active_model_serializers', '0.8.3'
gem 'activemodel-globalid', git: 'https://github.com/rails/activemodel-globalid'
gem 'activerecord-sqlserver-adapter'
gem 'acts_as_list', github: 'swanandp/acts_as_list', ref: '84325ede9ad528acbf68a97c5070cff113ee6a17'
gem 'american_date'
gem 'awesome_nested_set'
gem 'bootstrap-sass'
gem 'bourbon'
gem 'bugsnag'
gem 'carrierwave'
gem 'databasedotcom'
gem 'devise'
gem 'ember-cli-rails'
gem 'faraday_middleware'
gem 'fog'
gem 'gepub', '~> 0.7.0beta1'
gem 'kaminari'
gem 'migration_data'
gem 'mini_magick'
gem 'newrelic_rpm'
gem 'nokogiri'
gem 'omniauth-cas'
gem 'omniauth-oauth2'
gem 'ordinalize'
gem 'pdfkit'
gem 'pg_search'
gem 'pg'
gem 'premailer-rails'
gem 'puma'
gem 'pusher'
gem 'rack-timeout'
gem 'rails', '4.2.4'
gem 'request_store'
gem 'rest-client'
gem 'rubyzip', require: 'zip'
gem 'sass-rails'
gem 'sidekiq'
gem 'sinatra', require: nil
gem 'sort_alphabetical'
gem 'tahi_epub', git: 'https://ea548e3d06f18f2c5287468e46ae5fe262d3f5ac:x-oauth-basic@github.com/tahi-project/tahi_epub'
gem 'timeliness'
gem 'tiny_tds'
gem 'twitter-text'
gem 'uglifier'
gem 'unf'

group :staging, :production do
  gem 'heroku-deflater'
  gem 'rails_12factor'
end

group :development, :test do
  gem 'auto_screenshot', require: false
  gem 'dotenv-rails', require: 'dotenv/rails-now'
  gem 'generator_spec'
  gem 'progressbar'
  gem 'pry-rails'
  gem 'pry-remote'
  gem 'pry-rescue'
  gem 'quiet_assets'
end

group :development do
  gem 'awesome_print'
  gem 'bullet'
  gem 'foreman', require: false
  gem 'overcommit'
  gem 'rubocop'
end

group :staging do
  gem 'mail_safe'
end

group :test do
  gem 'capybara-screenshot'
  gem 'capybara'
  gem 'codeclimate-test-reporter', require: nil
  gem 'database_cleaner'
  gem 'email_spec'
  gem 'factory_girl_rails'
  gem 'pusher-fake'
  gem 'rspec_junit_formatter'
  gem 'rspec-activemodel-mocks'
  gem 'rspec-collection_matchers'
  gem 'rspec-instafail'
  gem 'rspec-its'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
  gem 'simplecov'
  gem 'thin'
  gem 'timecop'
  gem 'vcr'
  gem 'webmock'
end
