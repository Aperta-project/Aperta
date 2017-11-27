require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
require 'rspec/matchers'
require 'equivalent-xml'
require File.expand_path("../../config/environment", __FILE__)
require 'capybara/rspec'
require 'capybara-screenshot/rspec'
require 'email_spec'
require 'pusher-fake/support/rspec'
require 'rspec/rails'
require 'sidekiq/testing'
require 'webmock/rspec'
require 'rake'
require 'fakeredis/rspec'
require Rails.root.join('lib', 'tahi_plugin')
Dir[Rails.root.join('lib', 'custom_card', '**', '*.rb')].each { |f| require f }
include Warden::Test::Helpers

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
require_relative 'support/pages/page'
require_relative 'support/pages/overlay'
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

include FeatureLogoutHelper

# Load support & factories for installed Tahi plugins
TahiPlugin.plugins.each do |gem|
  Dir[File.join(gem.full_gem_path, 'spec', 'support', '**', '*.rb')].each { |f| require f }
  Dir[File.join(gem.full_gem_path, 'spec', 'factories', '**', '*.rb')].each { |f| require f }
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
# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema! if
  defined?(ActiveRecord::Migration)

# Truncate the database right now
DatabaseCleaner.clean_with(:truncation)

# Necessary to run a rake task from here
Rake::Task.clear
Tahi::Application.load_tasks
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
  config.order = 'random'

  config.include FeatureHelpers, type: :feature
  config.include Devise::TestHelpers, type: :controller
  config.include AuthorizationControllerSpecHelper, type: :controller
  config.include FactoryGirl::Syntax::Methods
  config.include TahiHelperMethods
  config.include EmailSpec::Helpers
  config.include EmailSpec::Matchers
  config.include HTMLHelpers

  config.before(:suite) do
    Warden.test_mode!
  end

  config.before(:context) do
    # Use the transactional strategy for all tests (except js tests, see below)
    DatabaseCleaner[:active_record].strategy = :transaction
  end

  config.before(:context, js: true) do
    # :truncation is the strategy we need to use for capybara tests, but do not
    # truncate task_types, cards, and card_contents, we want to keep these tables
    # around.
    # Ensure this comes after the generic setup (see above)
    DatabaseCleaner[:active_record].strategy = :truncation, {
      except: %w[task_types cards card_contents card_task_types card_versions entity_attributes]
    }

    # Fix to make sure this happens only once
    # This cannot be a :suite block, because that does not know if a js feature
    # is being run.
    # rubocop:disable Style/GlobalVars
    next if $capybara_setup_done
    EmberCLI.compile!
    Capybara.server_port = ENV['CAPYBARA_SERVER_PORT']

    # This allows the developer to specify a path to an older, insecure firefox
    # build for use in selenium tests. The value of the environment variable
    # should be a full path to the firefox binary.
    Selenium::WebDriver::Firefox::Binary.path = ENV['SELENIUM_FIREFOX_PATH'] if
      ENV['SELENIUM_FIREFOX_PATH']
    Capybara.register_driver :selenium do |app|
      profile = Selenium::WebDriver::Firefox::Profile.new
      ember_inspector_path = Rails.root.join('tmp/addon-470970-latest.xpi')
      # https://addons.mozilla.org/firefox/downloads/latest/ember-inspector/addon-470970-latest.xpi
      if File.exist?(ember_inspector_path)
        profile.add_extension(ember_inspector_path)
      elsif $stdout.tty?
        puts "\e[33mEmber inspector not installed in #{ember_inspector_path}\e[0m"
      end

      client = Selenium::WebDriver::Remote::Http::Default.new
      client.read_timeout = 90
      client.open_timeout = 90
      options = Selenium::WebDriver::Firefox::Options.new
      options.profile = profile
      Capybara::Selenium::Driver
        .new(app, browser: :firefox, options: options, http_client: client)
    end

    Capybara.javascript_driver = :selenium
    Capybara.default_max_wait_time = 10
    Capybara.wait_on_first_by_default = true

    # Store screenshots in artifacts dir on circle
    if ENV['CIRCLE_TEST_REPORTS']
      Capybara.save_path =
        "#{ENV['CIRCLE_TEST_REPORTS']}/screenshots/"
    end

    # Load question seeds before any tests start since we don't want them
    # to be rolled back as part of a transaction
    Rake::Task['cards:load'].reenable
    Rake::Task['cards:load'].invoke

    $capybara_setup_done = true
    # rubocop:enable Style/GlobalVars
  end

  config.before(:each) do
    ActionMailer::Base.deliveries.clear
    DatabaseCleaner.start
    Subscriptions.unsubscribe_all
    Sidekiq::Worker.clear_all
    UploadServer.clear_all_uploads
  end

  # Load subscriptions for feature specs. Make sure this comes *after*
  # unsubscribe_all. We need to add these back.
  config.before(:each, type: :feature) do
    Authorizations.reload_configuration
    Subscriptions.reload
    CardTaskType.seed_defaults
    Rake::Task['roles-and-permissions:seed'].reenable
    Rake::Task['roles-and-permissions:seed'].invoke
    Rake::Task['settings:seed_setting_templates'].reenable
    Rake::Task['settings:seed_setting_templates'].invoke
  end

  config.before(:each, type: :controller) do
    Authorizations.reload_configuration
  end

  # Use :pristine_roles_and_permissions when your test should have a blank
  # slate for R&P. When running feature specs and unit specs in random order
  # feature specs may have pre-loaded R&P as a speed optimization.
  config.before(:each, pristine_roles_and_permissions: true) do
    [Role, Permission, PermissionState].map(&:delete_all)
  end

  config.append_after(:each) do
    DatabaseCleaner.clean
  end

  config.after(:each) do
    Warden.test_reset!
  end
end
