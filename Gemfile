source 'https://rubygems.org'

ruby "2.1.5"

# Configuration
group :development, :test, :performance do
  gem 'dotenv'
  gem 'dotenv-deployment'
end

# Task Engines
gem 'plos_authors',           path: 'engines/plos_authors'
gem 'standard_tasks',         path: 'engines/standard_tasks'
gem 'supporting_information', path: 'engines/supporting_information'
gem 'upload_manuscript',      path: 'engines/upload_manuscript'

# Gems
gem 'rails', '4.2.0'
gem 'puma'
gem 'rack-timeout'
gem 'pg'
gem 'bower-rails'
gem 'ember-rails'
gem 'ember-source', '1.8.1'
gem "ember-data-source", "1.0.0.beta.14"
gem 'sass-rails'
gem 'haml-rails'
gem 'uglifier', '~> 2.5.0'
gem 'coffee-rails'
gem 'acts_as_list'
gem 'devise'
gem 'bourbon'
gem 'quiet_assets', '~> 1.0.3'
gem 'kaminari'

gem 'activemodel-globalid', git: 'https://github.com/rails/activemodel-globalid'
gem 'sidekiq'
gem 'sinatra'
gem 'active_record-acts_as'

gem "nokogiri"
gem "jquery-fileupload-rails", github: 'neo-tahi/jquery-fileupload-rails'
gem "carrierwave"
gem "fog"
gem "unf"
gem 'newrelic_rpm'
gem "rest_client", "~> 1.7.3"
gem 'gepub'
gem 'rubyzip', require: 'zip'
gem "active_model_serializers", "~> 0.8.3"
gem 'pry-rails'
gem 'pdfkit'
gem 'mail_form'
gem 'mini_magick'
gem 'timeliness'
gem 'twitter-text'
gem 'american_date'
gem 'omniauth-oauth2'
gem 'faraday_middleware'
gem 'ordinalize'
gem 'migration_data'
gem 'bugsnag'
gem 'sunspot_rails'

# NOTE: Using this fork because it uses a compatible omniauth version
# https://github.com/dlindahl/omniauth-cas/pull/28
gem 'omniauth-cas', github: "dandorman/omniauth-cas", ref: "83210ff52667c2c4574666dcfc9b577542fb595f"

gem 'tahi_epub', github: 'tahi-project/tahi_epub'

group :staging, :performance, :production do
  gem 'heroku-deflater'
  gem 'rails_12factor'
end

group :doc do
  gem 'sdoc', require: false
end

group :development do
  # gem 'rack-mini-profiler' # NOTE: this clashes with Teaspoon specs.
  # Please add it in temporarily if you need to check for speed
  gem 'bullet'
  gem 'kss-rails'
  gem 'letter_opener'
  gem 'rubocop', require: false
  gem 'scss-lint', require: false
  gem 'haml-lint', require: false
  gem 'overcommit', require: false
  gem 'reek', require: false
end

group :development, :test, :performance do
  gem 'factory_girl_rails'
  gem 'progressbar'
  gem 'rspec-rails'
  gem 'rspec-its'
  gem 'rspec-collection_matchers'
  gem 'rspec-instafail'
  gem 'launchy'
  gem 'database_cleaner'
  gem 'teaspoon', github: 'modeset/teaspoon'
  gem 'qunit-rails'
  gem 'phantomjs'
  gem 'pry-byebug'
  gem 'pry-stack_explorer'
  gem 'pry-rescue'
  gem 'foreman'
  gem 'sunspot_solr'
end

group :test do
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'capybara-webkit'
  gem 'simplecov'
  gem 'codeclimate-test-reporter', require: nil
  gem 'vcr'
  gem 'webmock'
  gem 'thin'
  gem 'sunspot-rails-tester'
end

group :staging, :performance do
  gem 'mail_safe'
end
