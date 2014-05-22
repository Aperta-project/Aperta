require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Cas < OmniAuth::Strategies::OAuth2
      option :name, "cas"

      option :client_options, {
        site: "http://localhost:8080/cas/",
        authorize_url: "http://localhost:8080/cas/oauth2.0/authorize",
        token_url: "http://localhost:8080/cas/oauth2.0/accessToken"
      }

      def profile
        {name: profile_response['id']}
      end

      uid do
        profile_response['id']
      end

      info { profile_response }

      def profile_response
        unless @profile_response
          url = "http://localhost:8080/cas/oauth2.0/profile?access_token=#{access_token.token}"
          conn = Faraday.new(url: url) do |faraday|
            faraday.response :json
            faraday.request :url_encoded
            faraday.adapter Faraday.default_adapter
          end
          response = conn.get
          @profile_response = response.body
        end
        @profile_response
      end
    end
  end
end
