source 'https://rubygems.org'

ruby "2.1.1"

gem 'rails', '4.1.0.rc1'
gem 'unicorn'
gem 'pg'
gem 'ember-rails'
gem 'ember-source', '1.5.0'
gem "ember-data-source", "~> 1.0.0.beta.7"
gem 'sass-rails', '~> 4.0.1'
gem 'haml-rails'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.1'
gem 'jquery-rails'
gem 'acts_as_list'
gem 'devise'
gem "bootstrap-sass"
gem 'bourbon'
gem 'rails_12factor', group: [:production, :staging]
gem "nokogiri"
gem "jquery-fileupload-rails", github: 'neo-tahi/jquery-fileupload-rails'
gem "carrierwave"
gem "fog"
gem "unf"
gem 'rails_admin'
gem "chosen-rails", "~> 1.0.2"
gem 'newrelic_rpm'
gem "rest_client", "~> 1.7.3"
gem 'gepub'
gem 'rubyzip', require: 'zip'
gem 'standard_tasks', path: 'engines/standard_tasks'
gem "active_model_serializers"
gem 'pry-rails'
gem 'pdfkit'

group :production, :staging do
  gem 'heroku-deflater'
end

group :doc do
  gem 'sdoc', require: false
end

group :development do
  # gem 'rack-mini-profiler' #NOTE: this clashes with Teaspoon specs. Please add it in temporarily if you need to check for speed
  gem 'pry-byebug'
  gem 'bullet'
  gem 'license_finder'
  gem 'railroady'
  gem 'spring'
end

group :development, :test do
  gem 'rspec-rails', "~> 3.0.0.beta2"
  gem "rspec-its", "~> 1.0.0.pre"
  gem 'capybara'
  gem 'capybara-webkit'
  gem 'selenium-webdriver'
  gem 'launchy'
  gem 'database_cleaner'
  gem "teaspoon"
  gem "phantomjs"
end

group :test do
  gem 'factory_girl_rails'
  gem "codeclimate-test-reporter", require: nil
  gem 'vcr'
  gem 'webmock'
end
