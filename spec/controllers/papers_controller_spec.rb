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
    it "returns http success" do
      get :new
      expect(response).to be_success
    end

    it "renders new template" do
      get :new
      expect(response).to render_template :new
    end
  end

  describe "POST 'create'" do
    before do
      post :create, {paper: {short_title: 'ABC101'}}
    end

    it "saves a new paper record" do
      expect(Paper.first).to be_persisted
    end

    it "assigns the paper to the current user" do
      expect(Paper.first.user).to eq(user)
    end

    it "redirects to edit paper page" do
      expect(response).to redirect_to(edit_paper_path Paper.first)
    end
  end

end
