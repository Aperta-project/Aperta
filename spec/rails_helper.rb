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

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
require_relative 'support/pages/page'
require_relative 'support/pages/overlay'
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# NOTE: This will stop working after we move the engines into their own repository.
Dir[Rails.root.join("engines/**/spec/support/**/*.rb")].each { |f| require f }
Dir[Rails.root.join("engines/**/spec/factories/**/*.rb")].each { |f| require f }

Capybara.server_port = ENV["CAPYBARA_SERVER_PORT"]
Capybara.server do |app, port|
  require 'rack/handler/thin'
  Rack::Handler::Thin.run(app, :Port => port)
end

Capybara.register_driver :selenium do |app|
  profile = Selenium::WebDriver::Firefox::Profile.new
  profile.add_extension("#{File.dirname(__FILE__)}/support/lib/ember_inspector-1.3.1-fx.xpi")
  Capybara::Selenium::Driver.new(app, :browser => :firefox, :profile => profile)
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
  config.ignore_request do |request|
    uri = URI(request.uri)
    host = uri.host
    port = uri.port
    (host == 'localhost' || host == '127.0.0.1') && (port == 8981 || port == 31_337 || port == 7055)
  end
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

  config.before(:each) do |example|
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.before(:each, solr: true) do
    Sunspot::Rails::Tester.start_original_sunspot_session
    Sunspot.session = $original_sunspot_session
    Sunspot.remove_all!
  end
end
