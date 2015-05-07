require 'rails_helper'

describe PlosAuthors::PlosAuthorsController do
  routes { PlosAuthors::Engine.routes }
  expect_policy_enforcement

  let(:user) { FactoryGirl.create(:user, :site_admin) }
  let(:task) { FactoryGirl.create(:plos_authors_task, completed: false) }
  let(:paper) { FactoryGirl.create(:paper) }
  let!(:author) { FactoryGirl.create(:plos_author, plos_authors_task: task)}

  before do
    sign_in user
  end

  describe "#create" do
    it "creates a plos author" do
      expect do
        post :create, format: :json, plos_author: { email: "spock@starwars.com", paper_id: paper.id }
      end.to change { PlosAuthors::PlosAuthor.count }.by(1)
      expect(response).to be_success
    end
  end

  describe "#update" do
    it "patches the plos author" do
      put :update, format: :json, id: author.id, plos_author: { email: "spock@startrek.com" }
      expect(author.reload.email).to eq("spock@startrek.com")
      expect(response).to be_success
    end
  end

  describe "#destroy" do
    it "eliminates the plos author" do
      expect do
        delete :destroy, format: :json, id: author.id
      end.to change { PlosAuthors::PlosAuthor.count }.by(-1)
      expect(response).to be_success
    end
  end

end
