require 'spec_helper'

describe UserInfoController do
  render_views
  let(:user) { create :user, admin: false }
  before { sign_in user }

  describe "GET 'dashboard'" do
    it "renders the dashboard info as json" do
      get :dashboard
      json = JSON.parse(response.body)
      expect(json.keys).to match_array %w(dashboard lite_papers card_thumbnails users affiliations)
    end
  end
end
