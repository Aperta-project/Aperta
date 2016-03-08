require 'rails_helper'

describe PaperTrackerQueriesController do
  let!(:journal) { FactoryGirl.create(:journal) }
  let(:user) { FactoryGirl.create :user, :site_admin }
  let!(:query) { FactoryGirl.create :paper_tracker_query }

  before { sign_in user }

  describe "#index" do
    it "returns a list of queries" do
      get :index, format: :json
      expect(response.status).to eq(200)
      expect(res_body['paper_tracker_queries'].length).to eq(1)
      expect(res_body['paper_tracker_queries'][0].keys)
        .to contain_exactly("id", "title", "query")
    end
  end

  describe "#create" do
    it "creates a paper tracker query" do
      (expect do
        post(
          :create,
          format: :json,
          paper_tracker_query: {
            title: "a title",
            query: "A QUERY or something"
          })
      end).to change { PaperTrackerQuery.count }.by(1)
    end
  end

  describe "#update" do
    it "updates an existing query record" do
      put :update, id: query.id, paper_tracker_query: { title: "A better title" }, format: :json
      expect(query.reload.title).to eq("A better title")
    end
  end

  describe "#destroy" do
    it "Deletes a paper tracker query" do
      delete :destroy, format: :json, id: query.id
      expect(query.reload.deleted).to eq(true)
    end
  end
end
