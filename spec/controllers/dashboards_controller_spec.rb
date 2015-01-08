require 'rails_helper'

describe DashboardsController do

  describe "GET 'show'" do
    let(:user) { create :user }
    before { sign_in user }

    let(:do_request) { get :show }

    it_behaves_like "when the user is not signed in"

    it "returns http success" do
      do_request
      expect(response).to be_success
    end

    it "renders the dashboard info as json" do
      do_request
      json = JSON.parse(response.body)
      expect(json.keys).to match_array %w(dashboards lite_papers users affiliations)
    end
  end

end
