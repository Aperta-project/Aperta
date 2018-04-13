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

# Generates URLs from resource names using Rails routes
# Can be mixed into ActiveRecord models to generate URLs
#
# Uses the host and port defined in the environment config file.
#
module UrlBuilder
  extend ActiveSupport::Concern

  included do
    delegate :url_helpers, to: 'Rails.application.routes'
  end

  # Given a resource_name (e.g., :root), return the
  # corresponding url (e.g., "http://www.example.com/")
  #
  def url_for(resource_name, options = {})
    rails_routing_options = { host: host, port: port }.merge(options)
    url_helpers.send("#{resource_name}_url", rails_routing_options)
  end

  private

  def host
    Rails.configuration.action_mailer.default_url_options[:host] || 'nohost'
  end

  def port
    Rails.configuration.action_mailer.default_url_options[:port]
  end
end
