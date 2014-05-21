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
        url = "http://localhost:8080/cas/oauth2.0/profile?access_token=#{access_token.token}"
        conn = Faraday.new(url: url) do |faraday|
          faraday.response :json
          faraday.request  :url_encoded
          faraday.adapter  Faraday.default_adapter
        end
        response = conn.get
        { name: response.body['id'] }
      end

      uid do
        access_token.token
      end

      info { profile }
    end
  end
end
