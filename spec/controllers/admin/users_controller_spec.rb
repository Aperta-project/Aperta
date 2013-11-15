require 'spec_helper'

describe Admin::UsersController do
  let(:permitted_params) { [:admin] }

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

    it "assigns users to be all users" do
      do_request
      expect(assigns :users).to match_array User.all
    end
  end

  describe "PUT 'update'" do
    subject(:do_request) { put :update, { id: user.to_param, user: { admin: false } } }

    it_behaves_like "when the user is not signed in"
    it_behaves_like "when the user is not an admin"

    it_behaves_like "a controller enforcing strong parameters" do
      let(:model_identifier) { :user }
      let(:expected_params) { permitted_params }
      let(:params_id) { user.to_param }
    end

    it "updates the user's attributes" do
      expect do
        do_request
      end.to change { user.reload.admin? }.from(true).to false
    end
  end

end
