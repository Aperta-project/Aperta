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

require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Orcid < OmniAuth::Strategies::OAuth2

      API_HOST = ENV['ORCID_API_HOST']
      SITE_HOST = ENV['ORCID_SITE_HOST']

      def self.options
        {
          site:        "https://#{API_HOST}",
          authorize_url: "http://#{SITE_HOST}/oauth/authorize",
          token_url:     "https://#{API_HOST}/oauth/token",
          scope:         "/read-limited",
          response_type: "code",
          mode:          :header
        }
      end

      def headers
        { 'Accept': 'application/json', 'Accept-Charset': 'UTF-8' }
      end

      option :client_options, options
      uid { access_token.params["orcid"] }
      info { access_token.get("/v2.0/#{uid}", headers: headers).parsed['person'] }
      extra { access_token.to_hash }
    end
  end
end
