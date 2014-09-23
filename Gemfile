source 'https://rubygems.org'

ruby "2.1.2"

# Configuration
group :development, :test, :performance do
  gem 'dotenv'
  gem 'dotenv-deployment'
end

# Task Engines
gem 'standard_tasks',         path: 'engines/standard_tasks'
gem 'supporting_information', path: 'engines/supporting_information'
gem 'upload_manuscript',      path: 'engines/upload_manuscript'

# Gems
gem 'rails', '4.1.1'
gem 'puma'
gem 'rack-timeout'
gem 'pg'
gem 'bower-rails'
gem 'ember-rails'
gem 'ember-source', '1.7.0'
gem "ember-data-source", "~> 1.0.0.beta.9"
gem 'sass-rails', '~> 4.0.3'
gem 'haml-rails'
gem 'uglifier', '~> 2.5.0'
gem 'coffee-rails', '~> 4.0.1'
gem 'acts_as_list'
gem 'devise'
gem 'bourbon'
gem 'quiet_assets', '~> 1.0.3'
gem 'kaminari'

gem 'activemodel-globalid', git: 'https://github.com/rails/activemodel-globalid'
gem 'sidekiq'
gem 'sinatra'

gem "nokogiri"
gem "jquery-fileupload-rails", github: 'neo-tahi/jquery-fileupload-rails'
gem "carrierwave"
gem "fog"
gem "unf"
gem 'rails_admin'
gem 'newrelic_rpm'
gem "rest_client", "~> 1.7.3"
gem 'gepub'
gem 'rubyzip', require: 'zip'
gem "active_model_serializers"
gem 'pry-rails'
gem 'pdfkit'
gem 'mini_magick'
gem 'timeliness'
gem 'american_date'
gem 'omniauth-oauth2'
gem 'faraday_middleware'
gem 'ordinalize'
gem 'migration_data'
gem 'bugsnag'
gem 'spring'
gem 'omniauth-cas', github: "dandorman/omniauth-cas", ref: "83210ff52667c2c4574666dcfc9b577542fb595f"
# NOTE: Using this fork because it uses a compatible omniauth version
# https://github.com/dlindahl/omniauth-cas/pull/28

group :staging, :performance, :production do
  gem 'heroku-deflater'
  gem 'rails_12factor'
end

group :doc do
  gem 'sdoc', require: false
end

group :development do
  # gem 'rack-mini-profiler' # NOTE: this clashes with Teaspoon specs. Please add it in temporarily if you need to check for speed
  gem 'bullet'
  gem 'kss-rails'
  gem 'letter_opener'
end

group :development, :test, :performance do
  gem 'factory_girl_rails'
  gem 'progressbar'
  gem 'rspec-rails'
  gem 'rspec-its'
  gem 'rspec-collection_matchers'
  gem 'rspec-instafail'
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'launchy'
  gem 'database_cleaner'
  gem 'teaspoon', github: 'modeset/teaspoon'
  gem 'qunit-rails'
  gem 'phantomjs'
  gem 'pry-byebug'
  gem 'pry-stack_explorer'
  gem 'pry-rescue'
end

group :test do
  gem "codeclimate-test-reporter", require: nil
  gem 'vcr'
  gem 'webmock'
  gem 'thin'
end

group :staging, :performance do
  gem 'mail_safe'
end
