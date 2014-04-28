require 'spec_helper'

describe UserInfoController do
  render_views
  let(:user) { FactoryGirl.create :user, admin: false }
  before { sign_in user }

  describe "GET 'dashboard'" do
    it "renders the dashboard info as json" do
      get :dashboard
      json = JSON.parse(response.body)
      expect(json.keys).to match_array %w(dashboard papers tasks users)
    end
  end
end
