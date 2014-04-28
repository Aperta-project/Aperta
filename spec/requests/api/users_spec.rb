require 'spec_helper'

describe Api::UsersController do
  describe "GET 'show'" do
    let(:user) { FactoryGirl.create :user }

    it "returns a single user" do
      get api_user_path(user.id)

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
  end
end
