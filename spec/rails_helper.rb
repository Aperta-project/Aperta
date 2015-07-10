if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start 'rails'
end

ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rspec'
require 'sidekiq/testing'
require 'pusher-fake/support/rspec'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
require_relative 'support/pages/page'
require_relative 'support/pages/overlay'
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

Tahi.service_log = Logger.new "#{::Rails.root}/log/service.log"

# Load support & factories for installed Tahi plugins
TahiPlugin.plugins.each do |gem|
  Dir[File.join(gem.full_gem_path, 'spec', 'support', '**', '*.rb')].each { |f| require f }
  Dir[File.join(gem.full_gem_path, 'spec', 'factories', '**', '*.rb')].each { |f| require f }
end

Capybara.server_port = ENV["CAPYBARA_SERVER_PORT"]

Capybara.register_driver :selenium do |app|
  profile = Selenium::WebDriver::Firefox::Profile.new
  if ENV['EMBER_DEBUG']
    profile.add_extension("#{File.dirname(__FILE__)}/support/lib/ember_inspector-1.8.0-fx.xpi")
  end
  client = Selenium::WebDriver::Remote::Http::Default.new
  client.timeout = 90
  Capybara::Selenium::Driver.new(app, browser: :firefox, profile: profile, http_client: client)
end

Capybara.javascript_driver = :selenium
Capybara.default_wait_time = 10

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema! if defined?(ActiveRecord::Migration)

if ENV['CI']
  require 'simplecov'
  require "codeclimate-test-reporter"
  SimpleCov.add_filter 'vendor'
  SimpleCov.formatters = []
  SimpleCov.start CodeClimate::TestReporter.configuration.profile
  RSpec.configure do |config|
    config.after(:suite) do
      CodeClimate::TestReporter::Formatter.new.format(SimpleCov.result)
    end
  end
end

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.allow_http_connections_when_no_cassette = false
  config.default_cassette_options = { record: :once }
  config.configure_rspec_metadata!
  config.ignore_hosts 'codeclimate.com'
  config.ignore_localhost = true
end

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = false

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/v/3-0/docs
  config.infer_spec_type_from_file_location!
  config.order = "random"

  config.include Devise::TestHelpers, type: :controller
  config.include FactoryGirl::Syntax::Methods
  config.include TahiHelperMethods
  config.extend TahiHelperClassMethods
  config.include Warden::Test::Helpers

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation, except: ['task_types'])
  end

  config.before(:each) do
    DatabaseCleaner[:active_record].strategy = :transaction
    DatabaseCleaner[:redis].strategy = :truncation
  end

  config.before(:each, js: true) do
    DatabaseCleaner[:active_record].strategy = :truncation, { except: ['task_types'] }
    DatabaseCleaner[:redis].strategy = :truncation
  end

  config.before(:each, redis: true) do
    DatabaseCleaner[:active_record].strategy = :truncation, { except: ['task_types'] }
    DatabaseCleaner[:redis].strategy = :truncation
    Sidekiq::Extensions::DelayedMailer.jobs.clear
  end

  config.before(:context, redis: true) do
    DatabaseCleaner.clean_with(:truncation, except: ['task_types'])
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.append_after(:each) do
    DatabaseCleaner.clean
  end
end
