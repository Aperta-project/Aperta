source 'https://rubygems.org'

# Remember to also change circle.yml and .ruby-version when the ruby version changes
ruby '2.2.3'

# Task Engines
gem 'plos_billing', path: 'engines/plos_billing'
gem 'plos_bio_internal_review', path: 'engines/plos_bio_internal_review'
gem 'plos_bio_tech_check', path: 'engines/plos_bio_tech_check'
gem 'tahi_standard_tasks', path: 'engines/tahi_standard_tasks'
gem 'tahi-assign_team', path: 'engines/tahi-assign_team'

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
gem 'fog', '~> 1.36.0'
gem 'gepub', '~> 0.7.0beta1'
gem 'kaminari'
gem 'lograge'
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
gem 'timeliness'
gem 'tiny_tds'
gem 'twitter-text'
gem 'uglifier'
gem 'unf'
# We need any version of yaml_db after 0.3.0 since it will namespace SerializationHelper
gem 'yaml_db', github: 'yamldb/yaml_db', ref: 'f980a67dfcfef76824676f3938b176b68c260e68' 

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
  gem 'fake_ftp'
  gem 'pusher-fake'
  gem 'rspec_junit_formatter'
  gem 'rspec-activemodel-mocks'
  gem 'rspec-collection_matchers'
  gem 'rspec-instafail'
  gem 'rspec-its'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
  gem 'simplecov'
  gem 'test_after_commit'
  gem 'thin'
  gem 'timecop'
  gem 'vcr'
  gem 'webmock'
end
