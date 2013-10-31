require 'spec_helper'

describe PapersController do

  ALLOWED_PARAMS = %i(short_title title abstract body)

  let :user do
    User.create! first_name: 'Albert',
      last_name: 'Einstein',
      email: 'einstein@example.org',
      password: 'password',
      password_confirmation: 'password',
      affiliation: 'Universität Zürich'
  end

  before { sign_in user }

  describe "GET 'new'" do
    subject(:do_request) { get :new }

    it_behaves_like "when the user is not signed in"

    it { should be_success }
    it { should render_template :new }
  end

  describe "POST 'create'" do
    subject(:do_request) do
      post :create, { paper: { short_title: 'ABC101' } }
    end

    it_behaves_like "when the user is not signed in"

    it_behaves_like "a controller enforcing strong parameters" do
      let(:model_identifier) { :paper }
      let(:allowed_params) { ALLOWED_PARAMS }
    end

    it "saves a new paper record" do
      do_request
      expect(Paper.first).to be_persisted
    end

    it "assigns the paper to the current user" do
      do_request
      expect(Paper.first.user).to eq(user)
    end

    it "redirects to edit paper page" do
      do_request
      expect(response).to redirect_to(edit_paper_path Paper.first)
    end
  end

  describe "PUT 'update'" do
    let(:paper) { Paper.create! }

    subject(:do_request) do
      put :update, { id: paper.to_param, paper: { short_title: 'ABC101' } }
    end

    it_behaves_like "when the user is not signed in"

    it_behaves_like "a controller enforcing strong parameters" do
      let(:params_id) { paper.to_param }
      let(:model_identifier) { :paper }
      let(:allowed_params) { ALLOWED_PARAMS }
    end

    it "redirects to dashboard" do
      do_request
      expect(response).to redirect_to(root_path)
    end

    it "updates the paper" do
      do_request
      expect(paper.reload.short_title).to eq('ABC101')
    end
  end
end
