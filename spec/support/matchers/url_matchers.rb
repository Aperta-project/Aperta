##
# Simple matcher to test if a string is a valid URL or not
#
require 'uri'

RSpec::Matchers.define :be_a_valid_url do
  match do |text|
    text =~ URI.regexp(%w(http https))
  end

  failure_message do |text|
    "Expected string '#{text}' to be a valid URL"
  end

  failure_message_when_negated do |text|
    "Expected string '#{text}' to not be a valid URL"
  end
end
