# require 'spec_helper' in your specs when you don't want to load dependencies

require 'simplecov'

if ENV['CIRCLE_ARTIFACTS']
  dir = File.join(ENV['CIRCLE_ARTIFACTS'], "coverage")
  SimpleCov.coverage_dir(dir)
end

SimpleCov.start do
  add_filter %r{^/test/}
  add_filter %r{^/spec/}
end

require 'rspec/instafail'
require 'rspec/retry'
require 'aasm/rspec'

RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  config.verbose_retry = true
  config.display_try_failure_messages = true

  config.around :each, type: :feature do |ex|
    ex.run_with_retry retry: 2
  end

  config.color = true
  config.filter_run focus: true
  config.formatter = 'RSpec::Instafail'
  config.pattern = '**/spec/**/*_spec.rb'
  config.run_all_when_everything_filtered = true
end
