# require 'spec_helper' in your specs when you don't want to load dependencies
require 'rspec/instafail'

RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  config.color = true
  config.filter_run focus: true
  config.formatter = 'RSpec::Instafail'
  config.pattern = 'engines/*/spec/**/*_spec.rb,spec/**/*_spec.rb'
  config.run_all_when_everything_filtered = true
end
