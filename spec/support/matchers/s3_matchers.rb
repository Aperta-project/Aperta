# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

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
    text.include? parse(url)
  end

  failure_message do |text|
    "Expected Amazon S3 url '#{parse(url)}' to match in:\n#{text}"
  end

  failure_message_when_negated do |text|
    "Expected Amazon S3 url '#{parse(url)}' not to match in:\n#{text}"
  end
end
