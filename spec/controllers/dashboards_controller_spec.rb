require 'spec_helper'

describe DashboardsController do

  let :user do
    user = User.create! first_name: 'Albert',
      last_name: 'Einstein',
      email: 'einstein@example.org',
      password: 'password',
      password_confirmation: 'password',
      affiliation: 'Universität Zürich'
    user
  end

  describe "GET 'index'" do
    context "when the user is not signed in" do
      before { sign_out :user }

      it "redirects to the sign in page" do
        get :index
        expect(response).to redirect_to new_user_session_path
      end
    end

    before { sign_in user }

    it "returns http success" do
      get :index
      expect(response).to be_success
    end

    it "renders the index template" do
      get :index
      expect(response).to render_template :index
    end
  end
end
