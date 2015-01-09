require 'rails_helper'

describe Api::UsersController do
  describe "GET 'show'" do
    let(:user) { create :user }
    let(:api_token) { ApiKey.generate! }

    it "returns a single user" do
      get api_user_path(user.id), nil, authorization: ActionController::HttpAuthentication::Token.encode_credentials(api_token)

      data = JSON.parse response.body
      expect(data['users'].length).to eq 1
      expect(data).to eq(
        {
          users: [
            { id: user.id, first_name: user.first_name, last_name: user.last_name }
          ]
        }.with_indifferent_access
      )
    end

    context "when there is no API token provided" do
      it "doesn't return a list of journals in the system" do
        get api_user_path(user.id)
        expect(response.status).to eq(401)
      end
    end
  end
end
