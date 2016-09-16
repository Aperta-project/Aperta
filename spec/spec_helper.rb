# require 'spec_helper' in your specs when you don't want to load dependencies
require 'rspec/instafail'
require 'rspec/retry'

RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  config.verbose_retry = true
  config.display_try_failure_messages = true

  config.around :each, :flaky do |ex|
    ex.run_with_retry retry: 3
  end

  config.color = true
  config.filter_run focus: true
  config.formatter = 'RSpec::Instafail'
  config.pattern = '**/spec/**/*_spec.rb'
  config.run_all_when_everything_filtered = true
end
