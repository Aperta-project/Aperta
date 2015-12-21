require 'rails_helper'

describe PaperTrackerController do
  let(:user) { FactoryGirl.create :user, site_admin: true }

  before { sign_in user }

  describe "on GET #index" do

    it "list the paper in journal that user belongs to" do
      paper = FactoryGirl.create(:paper, :submitted)
      assign_journal_role(paper.journal, user, :admin)
      get :index, format: :json
      json = JSON.parse(response.body)
      expect(json["papers"].size).to eq 1
      expect(json["papers"][0]["title"]).to eq paper.title
    end

    it "do not list the paper if is not submitted" do
      paper = FactoryGirl.create(:paper)
      assign_journal_role(paper.journal, user, :admin)
      get :index, format: :json
      json = JSON.parse(response.body)
      expect(json["papers"].size).to eq 0
    end

    it "do not list the paper where user do not have a old_role" do
      paper = FactoryGirl.create(:paper, :submitted)
      get :index, format: :json
      json = JSON.parse(response.body)
      expect(json["papers"].size).to eq 0
    end
  end
end
