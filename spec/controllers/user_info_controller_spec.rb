require 'spec_helper'

describe UserInfoController do
  render_views
  let(:user) { FactoryGirl.create :user, admin: false }
  before { sign_in user }

  describe "GET 'thumbnails'" do
    it "returns an array of user info" do
      get :thumbnails
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json['users'].count).to eq(1)
      expect(json['users'].first).to include('id', 'fullName', 'imageUrl')
    end
  end
end
