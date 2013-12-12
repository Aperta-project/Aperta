require 'spec_helper'

describe Admin::JournalsController do
  let :user do
    User.create! username: 'albert',
      first_name: 'Albert',
      last_name: 'Einstein',
      email: 'einstein@example.org',
      password: 'password',
      password_confirmation: 'password',
      affiliation: 'Universität Zürich',
      admin: true
  end

  before { sign_in user }

  describe "GET 'index'" do
    subject(:do_request) { get :index }

    it { should be_success }
    it { should render_template :index }

    it_behaves_like "when the user is not signed in"
    it_behaves_like "when the user is not an admin"

    it "assigns journals to be all journals" do
      do_request
      expect(assigns :journals).to match_array Journal.all
    end
  end
end
