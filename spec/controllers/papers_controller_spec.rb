require 'spec_helper'

describe PapersController do

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

end
