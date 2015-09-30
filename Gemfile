source 'https://rubygems.org'

# Remember to also change circle.yml and .ruby-gemset when the ruby version changes
ruby "2.2.2"

# Configuration
group :development, :test, :performance do
  gem 'dotenv-rails', :require => 'dotenv/rails-now'
end

# Task Engines
gem 'tahi_standard_tasks', path: 'engines/tahi_standard_tasks'
gem 'tahi_upload_manuscript', path: 'engines/tahi_upload_manuscript'
gem 'plos_bio_tech_check', git: "https://f11148f2df58b9d5966b2543f6a0d3c035985f88:x-oauth-basic@github.com/tahi-project/plos_bio_tech_check"
gem 'plos_bio_internal_review', git: 'https://f11148f2df58b9d5966b2543f6a0d3c035985f88:x-oauth-basic@github.com/tahi-project/plos_bio_internal_review'
gem 'plos_billing', path: 'engines/plos_billing'
gem 'tahi-assign_team', git: 'https://f11148f2df58b9d5966b2543f6a0d3c035985f88:x-oauth-basic@github.com/tahi-project/tahi-assign_team'
# Gems
gem 'rails', '4.2.4'
gem 'puma'
gem 'rack-timeout'
gem 'pg'
gem 'ember-cli-rails'
gem 'sass-rails'
gem 'uglifier'
gem 'acts_as_list', github: 'swanandp/acts_as_list', ref: "84325ede9ad528acbf68a97c5070cff113ee6a17"
gem 'devise'
gem 'bourbon'
gem 'kaminari'

gem 'activemodel-globalid', git: 'https://github.com/rails/activemodel-globalid'
gem 'sidekiq'
gem 'sidetiq'
gem 'sinatra'
gem 'request_store'

gem "premailer-rails"
gem "nokogiri"
gem "carrierwave"
gem "fog"
gem "unf"
gem 'newrelic_rpm'
gem "rest-client"
gem 'gepub', "~> 0.7.0beta1"
gem 'rubyzip', require: 'zip'
gem "active_model_serializers", "0.8.3"
gem 'pdfkit'
gem 'mini_magick'
gem 'timeliness'
gem 'twitter-text'
gem 'american_date'
gem 'omniauth-oauth2'
gem 'faraday_middleware'
gem 'ordinalize'
gem 'migration_data'
gem 'bugsnag'
gem 'pg_search'
gem 'aasm', "~> 4.1.0"
gem 'bootstrap-sass'
gem 'pusher'
gem 'omniauth-cas'
gem 'databasedotcom'
gem 'sort_alphabetical'
gem 'tahi_epub', git: "https://f11148f2df58b9d5966b2543f6a0d3c035985f88:x-oauth-basic@github.com/tahi-project/tahi_epub"
gem 'awesome_nested_set'

group :staging, :performance, :production do
  gem 'heroku-deflater'
  gem 'rails_12factor'
end

group :doc do
  gem 'sdoc', require: false
end

group :development, :test, :performance do
  gem 'auto_screenshot', require: false
  gem 'factory_girl_rails'
  gem 'progressbar'
  gem 'rspec-rails'
  gem 'rspec-its'
  gem 'rspec-collection_matchers'
  gem 'rspec-instafail'
  gem 'launchy'
  gem 'database_cleaner'
  gem 'pry-rescue'
  gem 'pry-rails'
  gem 'pry-remote'
  gem 'foreman'
  gem 'quiet_assets'
  gem 'generator_spec'
  gem 'awesome_print'
end

group :development do
  gem 'bullet'
end

group :test do
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'email_spec'
  gem 'selenium-webdriver'
  gem 'simplecov'
  gem 'codeclimate-test-reporter', require: nil
  gem 'vcr'
  gem 'webmock'
  gem 'thin'
  gem 'timecop'
  gem 'pusher-fake'
  gem 'rspec_junit_formatter'
end

group :staging, :performance do
  gem 'mail_safe'
end
