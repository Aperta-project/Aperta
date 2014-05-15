require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Orcid < OmniAuth::Strategies::OAuth2

      DEFAULT_SCOPE = '/orcid-bio/read-limited'

      def self.options
        { site:        "http://#{api_host}",
        authorize_url: "http://#{site_host}/oauth/authorize",
        token_url:     "https://#{api_host}/oauth/token",
        scope:         "/orcid-profile/read-limited",
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

      option :client_options, options
      uid {  access_token.params["orcid"] }
      info { Hash.new }

    end
  end
end
