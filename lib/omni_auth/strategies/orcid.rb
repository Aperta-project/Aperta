require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Orcid < OmniAuth::Strategies::OAuth2

      DEFAULT_SCOPE = '/orcid-bio/read-limited'

      option :client_options, {
        :site => 'http://api.sandbox.orcid.org',
        :authorize_url => 'http://sandbox.orcid.org/oauth/authorize',
        :token_url => 'https://api.sandbox.orcid.org/oauth/token',
        :scope => '/orcid-profile/read-limited',
        :response_type => 'code',
        :mode => :header
      }


      # Pull out unique ID for the user in the external system
      uid {  access_token.params["orcid"] }

      info do{} end

      # Customize the parameters passed to the OAuth provider in the authorization phase
      def authorize_params
        # Trick shamelessly borrowed from the omniauth-facebook gem! 
        super.tap do |params|
          %w[scope].each { |v| params[v.to_sym] = request.params[v] if request.params[v] }
          params[:scope] ||= DEFAULT_SCOPE # ensure that we're always request *some* default scope
        end
      end
    end
  end
end
