# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

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
        .to contain_exactly("id", "title", "query", "order_by", "order_dir")
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

    it "returns a 204 (no content) status" do
      delete :destroy, format: :json, id: query.id
      expect(response.status).to eq(204)
    end

    it "logs the deleted query" do
      expect(Rails.logger).to receive(:info).with("#{user.email} deleted query #{query.title}")
      delete :destroy, format: :json, id: query.id
    end
  end
end
