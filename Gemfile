source 'https://rubygems.org'

ruby "2.1.4"

# Task Engines
gem 'plos_authors',           path: 'engines/plos_authors'
gem 'standard_tasks',         path: 'engines/standard_tasks'
gem 'supporting_information', path: 'engines/supporting_information'
gem 'upload_manuscript',      path: 'engines/upload_manuscript'

# Gems
gem "active_model_serializers"
gem "carrierwave"
gem "ember-data-source", "~> 1.0.0.beta.9"
gem "fog"
gem "jquery-fileupload-rails", github: 'neo-tahi/jquery-fileupload-rails'
gem "nokogiri"
gem "rest_client", "~> 1.7.3"
gem "unf"
gem 'active_record-acts_as'
gem 'activemodel-globalid', git: 'https://github.com/rails/activemodel-globalid'
gem 'acts_as_list'
gem 'american_date'
gem 'bourbon'
gem 'bower-rails'
gem 'bugsnag'
gem 'coffee-rails', '~> 4.0.1'
gem 'devise'
gem 'ember-rails'
gem 'ember-source', '1.7.0'
gem 'faraday_middleware'
gem 'gepub'
gem 'haml-rails'
gem 'kaminari'
gem 'mail_form'
gem 'migration_data'
gem 'mini_magick'
gem 'newrelic_rpm'
gem 'omniauth-oauth2'
gem 'ordinalize'
gem 'pdfkit'
gem 'pg'
gem 'pry-rails'
gem 'puma'
gem 'quiet_assets', '~> 1.0.3'
gem 'rack-timeout'
gem 'rails', '4.1.7'
gem 'rubyzip', require: 'zip'
gem 'sass-rails', '~> 4.0.4'
gem 'sidekiq'
gem 'sinatra'
gem 'spring'
gem 'sunspot_rails'
gem 'tahi_epub', github: 'tahi-project/tahi_epub'
gem 'timeliness'
gem 'twitter-text'
gem 'uglifier', '~> 2.5.0'

# NOTE: Using this fork because it uses a compatible omniauth version
# https://github.com/dlindahl/omniauth-cas/pull/28
gem('omniauth-cas',
    github: "dandorman/omniauth-cas",
    ref: "83210ff52667c2c4574666dcfc9b577542fb595f")

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
  gem 'overcommit', require: false
  gem 'reek', require: false
  gem 'rubocop', require: false
  gem 'scss-lint', require: false
end

group :development, :test, :performance do
  gem 'capybara'
  gem 'capybara-webkit'
  gem 'database_cleaner'
  gem 'dotenv'
  gem 'dotenv-deployment'
  gem 'factory_girl_rails'
  gem 'foreman'
  gem 'launchy'
  gem 'phantomjs'
  gem 'progressbar'
  gem 'pry-byebug'
  gem 'pry-rescue'
  gem 'pry-stack_explorer'
  gem 'qunit-rails'
  gem 'rspec-collection_matchers'
  gem 'rspec-instafail'
  gem 'rspec-its'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
  gem 'sunspot_solr'
  gem 'teaspoon', github: 'modeset/teaspoon'
end

group :test do
  gem 'codeclimate-test-reporter', require: nil
  gem 'simplecov'
  gem 'sunspot-rails-tester'
  gem 'thin'
  gem 'vcr'
  gem 'webmock'
end

group :staging, :performance do
  gem 'mail_safe'
end
