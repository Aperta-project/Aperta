source 'https://rubygems.org'

# Remember to also change circle.yml and .ruby-version when the
# ruby version changes
ruby '2.3.6'

# Gems
gem 'aasm', '~> 4.9.0'
gem 'active_model_serializers', '0.8.3'
gem 'activemodel-globalid', git: 'https://github.com/rails/activemodel-globalid'
gem 'activerecord-import'
gem 'acts_as_list', '~> 0.9.0'
gem 'american_date'
gem 'awesome_nested_set'
gem 'bootstrap-sass'
gem 'bourbon'
gem 'browser'
gem 'bugsnag'
gem 'carrierwave'
gem 'closure_tree'
gem 'combine_pdf'
gem 'databasedotcom'
gem 'devise', '~> 3.5.6'
gem 'ember-cli-rails'
gem 'faraday'
gem 'faraday_middleware', '~> 0.10'
gem 'fog', '~> 1.36.0'
gem 'gepub', '~> 0.7.0beta4'
gem 'jwt'
gem 'kaminari'
gem 'liquid'
gem 'lograge'
gem 'mail_safe', require: false
gem 'migration_comments'
gem 'migration_data'
gem 'mini_magick'
gem 'newrelic_rpm'
gem 'nokogiri', '>= 1.7.2'
gem 'omniauth', '~> 1.3.2'
gem 'omniauth-cas', '1.1.1'
gem 'omniauth-oauth2'
gem 'ordinalize'
gem 'origami'
gem 'paper_trail'
gem 'pdfkit'
gem 'pg'
gem 'pg_search'
gem 'premailer-rails'
gem 'puma'
gem 'pusher'
gem 'rack-protection', '~> 1.5.5'
gem 'rack-timeout'
gem 'rails', '~>4.2.10'
gem 'rbtrace'
gem 'render_anywhere', require: nil
gem 'request_store'
gem 'rest-client'
gem 'rsec'
gem 'ruby-jing'
gem 'ruby_dig'
gem 'rubyzip', '>=1.2.1', require: 'zip'
gem 'sass-rails'
gem 'sdoc'
gem 'sidekiq'
gem 'sidekiq-scheduler'
gem 'sidekiq-unique-jobs'
gem 'sinatra', require: nil # used by sidekiq and for tests
gem 'sort_alphabetical'
gem 'syslogger'
gem 'timeliness'
gem 'tiny_tds'
gem 'twitter-text'
gem 'unf'
gem 'whenever'
gem 'yaml_db'

# has_secure_token has been accepted into rails, but isn't yet in the most
# recent release (4.2.5) Remove this gem when we upgrade to a rails version
# with this included
gem 'has_secure_token'

group :staging, :production do
  # The dotenv binary is used to load our environment in staging & production
  gem 'dotenv', require: false
end

group :staging do
  gem 'heroku-deflater'
  gem 'rails_12factor'
end

group :development, :test do
  gem 'awesome_print'
  gem 'bootsnap'
  gem 'dotenv-rails', require: 'dotenv/rails-now'
  gem 'progressbar'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'pry-remote'
  gem 'pry-rescue'
  gem 'quiet_assets'
  gem 'rspec-rails' # This needs to be in the development group to make rake tasks work
end

group :development do
  gem 'aws-sdk', '~> 2'
  gem 'brakeman'
  gem 'bullet'
  gem 'capistrano-chruby'
  gem 'capistrano-rails'
  gem 'foreman', require: false
  gem 'overcommit'
  gem 'rubocop'
  gem 'spring'
  gem 'spring-commands-rspec'
end

group :test do
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'capybara-select2'
  gem 'climate_control'
  gem 'codeclimate-test-reporter', require: nil
  gem 'database_cleaner'
  gem 'db-query-matchers'
  gem 'email_spec'
  gem 'equivalent-xml'
  gem 'factory_girl_rails'
  gem 'fake_ftp'
  gem 'faker'
  gem 'fakeredis'
  gem 'geckodriver-helper'
  gem 'generator_spec'
  gem 'pusher-fake'
  gem 'rspec-activemodel-mocks'
  gem 'rspec-collection_matchers'
  gem 'rspec-instafail'
  gem 'rspec-retry'
  gem 'rspec_junit_formatter'
  gem 'selenium-webdriver'
  gem 'simplecov'
  gem 'test_after_commit'
  gem 'thin'
  gem 'timecop'
  gem 'vcr'
  gem 'webmock'
end
