require 'spec_helper'

describe Api::PapersController do
  let!(:paper1) { FactoryGirl.create(:paper,
                                     short_title: "paper-2",
                                     title: "First paper",
                                     paper_type: 'front_matter',
                                     authors: [{ first_name: 'Ryan',
                                                 last_name: 'Wold',
                                                 affiliation: 'Personal',
                                                 email: 'user@example.com' }]) }

  describe "GET 'index'" do
    let!(:paper2) { FactoryGirl.create(:paper,
                                       short_title: "paper-1",
                                       title: "Second paper") }

    it "user can get a list of papers" do
      get api_papers_path

      expect(JSON.parse(response.body)).to eq(
        {
          papers: [
            { id: paper1.id, title: "First paper",
              authors: [{ first_name: 'Ryan', last_name: 'Wold', affiliation: 'Personal', email: 'user@example.com' }],
              paper_type: 'front_matter' },
            { id: paper2.id, title: "Second paper", authors: [], paper_type: 'research' }
          ]
        }.with_indifferent_access
      )
    end
  end

  describe "GET 'show'" do
    it "user can get a single paper" do
      get api_paper_path(paper1.id)

      data = JSON.parse response.body
      expect(data['papers'].length).to eq 1
      expect(data).to eq(
        {
          papers: [
            { id: paper1.id, title: "First paper",
              authors: [{ first_name: 'Ryan', last_name: 'Wold', affiliation: 'Personal', email: 'user@example.com' }],
              paper_type: 'front_matter' }
          ]
        }.with_indifferent_access
      )
    end
  end

  describe "PATCH 'published_at'" do
    context "whitelisted attribute" do
      it "updates the published_at attribute for a paper" do
        patch_params = %Q{[{ "op": "replace", "path": "/papers/#{paper1.id}/publishedAt", "value": "2014-03-21" }]}
        patch api_paper_path(paper1.id), patch_params, { 'CONTENT_TYPE' => "application/json-patch+json",
                                                         'ACCEPT' => "application/vnd.api+json" }

        expect(response.body).to_not be_nil
        expect(response.status).to eq 204
        expect(paper1.reload.published_at).to eq("2014-03-21")
      end
    end

    context "non-whitelisted attribute" do
      it "does not update when attribute is not whitelisted for a paper" do
        patch_params = %Q{[{ "op": "replace", "path": "/papers/#{paper1.id}/createdAt", "value": "2014-03-21" }]}
        patch api_paper_path(paper1.id), patch_params, { 'CONTENT_TYPE' => "application/json-patch+json",
                                                         'ACCEPT' => "application/vnd.api+json" }

        expect(response.status).to eq 401
        expect(paper1.reload.created_at).to_not eq "2014-03-21"
      end

    end
  end
end
