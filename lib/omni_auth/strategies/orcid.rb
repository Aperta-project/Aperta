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

      DEFAULT_SCOPE = '/orcid-bio/read-limited'
      API_HOST = ENV['ORCID_API_HOST']
      SITE_HOST = ENV['ORCID_SITE_HOST']

      def self.options
        { site:        "http://#{API_HOST}",
        authorize_url: "http://#{SITE_HOST}/oauth/authorize",
        token_url:     "https://#{API_HOST}/oauth/token",
        scope:         "/orcid-bio/read-limited",
        response_type: "code",
        mode:          :header }
      end

      # Customize the parameters passed to the OAuth provider in the authorization phase
      def authorize_params
        super.tap do |params|
          %w(scope).each { |v| params[v.to_sym] = request.params[v] if request.params[v] }
          params[:scope] ||= DEFAULT_SCOPE # ensure that we're always request *some* default scope
        end
      end

      def profile
        url = "https://#{API_HOST}/v1.2/#{uid}/orcid-profile"
        conn = Faraday.new(url: url) do |faraday|
          faraday.response :xml
          faraday.request  :url_encoded
          faraday.adapter  Faraday.default_adapter
        end
        response = conn.get do |req|
          req.headers['Content-Type']  = "application/vdn.orcid+xml"
          req.headers['Authorization'] = "Bearer #{access_token.token}"
        end
        response.body['orcid_message']['orcid_profile']
      end

      option :client_options, options
      uid { access_token.params["orcid"] }
      info { profile }

    end
  end
end
