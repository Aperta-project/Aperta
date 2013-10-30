require 'spec_helper'

describe PapersController do

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
    it "saves a new paper record" do
      post :create, {paper: {short_title: 'ABC101'}}
      expect(Paper.first).to be_persisted
    end

    it "redirects to edit paper page" do
      post :create, {paper: {short_title: 'ABC101'}}
      expect(response).to redirect_to(edit_paper_path Paper.first)
    end
  end

end
