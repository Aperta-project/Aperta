require 'rails_helper'

describe PaperTrackerController do
  let(:user) { FactoryGirl.create :user }

  before { sign_in user }

  describe "on GET #index" do

    it "list the paper where user have a role" do
      paper = FactoryGirl.create(:paper, :submitted)
      assign_paper_role(paper, user, PaperRole::ADMIN)
      get :index, format: :json
      json = JSON.parse(response.body)
      expect(json["papers"].size).to eq 1
      expect(json["papers"][0]["title"]).to eq paper.title
    end

    it "do not list the paper if is not submitted" do
      paper = FactoryGirl.create(:paper)
      assign_paper_role(paper, user, PaperRole::ADMIN)
      get :index, format: :json
      json = JSON.parse(response.body)
      expect(json["papers"].size).to eq 0
    end

    it "do not list the paper where user do not have a role" do
      get :index, format: :json
      json = JSON.parse(response.body)
      expect(json["papers"].size).to eq 0
    end
  end
end
