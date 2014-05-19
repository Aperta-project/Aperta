require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Orcid < OmniAuth::Strategies::OAuth2

      DEFAULT_SCOPE = '/orcid-bio/read-limited'

      def self.options
        { site:        "http://#{api_host}",
        authorize_url: "http://#{site_host}/oauth/authorize",
        token_url:     "https://#{api_host}/oauth/token",
        scope:         "/orcid-bio/read-limited",
        response_type: "code",
        mode:          :header }
      end

      # Customize the parameters passed to the OAuth provider in the authorization phase
      def authorize_params
        super.tap do |params|
          %w[scope].each { |v| params[v.to_sym] = request.params[v] if request.params[v] }
          params[:scope] ||= DEFAULT_SCOPE # ensure that we're always request *some* default scope
        end
      end

      def self.api_host
        if Rails.env.production?
          "api.orcid.org"
        else
          "api.sandbox.orcid.org"
        end
      end

      def self.site_host
        if Rails.env.production?
          "orcid.org"
        else
          "sandbox.orcid.org"
        end
      end

      def profile
        url = "https://#{self.class.api_host}/v1.1/#{uid}/orcid-profile"
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
