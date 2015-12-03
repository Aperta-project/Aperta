require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'capybara-screenshot/rspec'
require 'capybara/rspec'
require 'email_spec'
require 'pusher-fake/support/rspec'
require 'rspec/rails'
require 'sidekiq/testing'
require 'webmock/rspec'
include Warden::Test::Helpers

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
require_relative 'support/pages/page'
require_relative 'support/pages/overlay'
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Build our ember app NOW and not on demand
EmberCLI.compile!

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
    profile.add_extension("#{File.dirname(__FILE__)}/support/lib/ember_inspector-1.8.3-fx.xpi")
  end
  client = Selenium::WebDriver::Remote::Http::Default.new
  client.timeout = 90
  Capybara::Selenium::Driver.new(app, browser: :firefox, profile: profile, http_client: client)
end

Capybara.javascript_driver = :selenium
Capybara.default_max_wait_time = 10
Capybara.wait_on_first_by_default = true

# Store screenshots in artifacts dir on circle
if ENV['CIRCLE_TEST_REPORTS']
  Capybara.save_and_open_page_path = "#{ENV['CIRCLE_TEST_REPORTS']}/screenshots/"
end

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema! if defined?(ActiveRecord::Migration)

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
  config.include EmailSpec::Helpers
  config.include EmailSpec::Matchers

  Warden.test_mode!

  config.before(:suite) do
    # Load question seeds before any tests start since we don't want them
    # to be rolled back as part of a transaction
    %x{rake nested-questions:seed}

    DatabaseCleaner.clean_with(:truncation, except: ['task_types', 'nested_questions'])
  end

  # Don't load subscriptions for unit specs
  config.before(:each) do
    Subscriptions.unsubscribe_all
  end

  # Load subscriptions for feature specs
  config.before(:each, type: :feature) do
    Subscriptions.reload
  end

  config.before(:each) do
    DatabaseCleaner[:active_record].strategy = :transaction
    DatabaseCleaner[:redis].strategy = :truncation
  end

  config.before(:each, js: true) do
    DatabaseCleaner[:active_record].strategy = :truncation, { except: ['task_types', 'nested_questions'] }
    DatabaseCleaner[:redis].strategy = :truncation
  end

  config.before(:each, redis: true) do
    DatabaseCleaner[:active_record].strategy = :truncation, { except: ['task_types', 'nested_questions'] }
    DatabaseCleaner[:redis].strategy = :truncation
    Sidekiq::Extensions::DelayedMailer.jobs.clear
  end

  config.before(:each) do
    UploadServer.clear_all_uploads
  end

  config.before(:each) do
    Sidekiq::Worker.clear_all
  end

  config.before(:context, redis: true) do
    DatabaseCleaner.clean_with(:truncation, except: ['task_types', 'nested_questions'])
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.append_after(:each) do
    DatabaseCleaner.clean
  end

  config.before(:each) do
    ActionMailer::Base.deliveries.clear
  end

  config.before(:each, js: true) do
    Capybara.page.driver.browser.manage.window.resize_to(1500, 1000)
  end

  config.after(:each) do
    Warden.test_reset!
  end
end
