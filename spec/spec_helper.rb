require "codeclimate-test-reporter"
CodeClimate::TestReporter.start
# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
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

Capybara.javascript_driver = :webkit

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.allow_http_connections_when_no_cassette = false
  config.default_cassette_options = { record: :once }
  config.configure_rspec_metadata!
  config.ignore_localhost = true # Makes Selenium work
  config.ignore_hosts 'codeclimate.com'
end

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explictly tag your specs with their type, e.g.:
  #
  #     describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/v/3-0/docs
  config.infer_spec_type_from_file_location!

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
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

  config.include Haml::Helpers, type: :helper
  config.before(:each, type: :helper) do
    init_haml_helpers
  end

  config.before(:context, redis: true) do
    DatabaseCleaner.clean_with(:truncation, except: ['task_types'])
  end

  config.before(:each) do |example|
    @current_driver = Capybara.current_driver
    if example.metadata[:selenium].present? || ENV["SELENIUM"] == "true"
      Capybara.current_driver = :selenium
    end
    DatabaseCleaner.start
  end

  config.after(:each) do
    Capybara.current_driver = @current_driver
    DatabaseCleaner.clean
  end
end
