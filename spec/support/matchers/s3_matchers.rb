##
# Allow scanning for Amazon S3 URLs ignoring querystring data
#
# Amazon S3 URLs often have extraneous data tacked on for expiration
# and signage.  This matcher is useful to find URLs in any given text
# while ignoring this querystring data.
#
require 'uri'

RSpec::Matchers.define :have_s3_url do |url|
  def parse(url)
    # remove any s3 signing
    uri = URI.parse(url)
    [uri.host, uri.path].join
  rescue
    url
  end

  match do |text|
    !text.at(parse(url)).nil?
  end

  failure_message do |text|
    "Expected Amazon S3 url '#{parse(url)}' to match in:\n#{text}"
  end

  failure_message_when_negated do |text|
    "Expected Amazon S3 url '#{parse(url)}' not to match in:\n#{text}"
  end
end
