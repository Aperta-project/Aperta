require 'spec_helper'

describe DashboardsController do

  let :user do
    User.create! first_name: 'Albert',
      last_name: 'Einstein',
      email: 'einstein@example.org',
      password: 'password',
      password_confirmation: 'password',
      affiliation: 'Universität Zürich'
  end

  describe "GET 'index'" do
    subject(:do_request) { get :index }

    it_behaves_like "when the user is not signed in"

    before { sign_in user }

    it { should be_success }
    it { should render_template :index }

    describe "papers" do
      before do
        Paper.create!
        Paper.create! user: user
      end

      it "assigns papers" do
        do_request
        expect(assigns(:papers)).to match_array user.papers
      end
    end

  end
end
