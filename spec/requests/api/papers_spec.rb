require 'rails_helper'

describe Api::PapersController do
  let!(:author) { FactoryGirl.create(:author) }
  let!(:paper1) { FactoryGirl.create(:paper, :with_tasks,
                                     short_title: "paper-2",
                                     title: "First paper",
                                     authors: [author]) }
  let(:api_token) { ApiKey.generate! }

  def paper_json_attrs(paper)
    {"id" => paper.id,
     "title" => paper.title,
     "paper_type" => paper.paper_type,
     "epub" => "http://www.example.com/api/papers/#{paper.id}.epub",
     "author_ids" => paper.authors.collect(&:id)}
  end

  def author_json_attrs(author)
    {"id" => author.id,
     "first_name" => author.first_name,
     "last_name" => author.last_name,
     "paper_id" => author.paper.id,
     "position" => author.position}
  end

  describe "GET 'index'" do
    let!(:paper2) { FactoryGirl.create(:paper, :with_tasks,
                                       short_title: "paper-1",
                                       title: "Second paper") }

    it "user can get a list of papers" do
      get api_papers_path, nil,
        authorization: ActionController::HttpAuthentication::Token.encode_credentials(api_token)

      expect(JSON.parse(response.body)["authors"]).to match_array([author_json_attrs(author)])
      expect(JSON.parse(response.body)["papers"]).to match_array([paper_json_attrs(paper1), paper_json_attrs(paper2)])
    end

    context "when the published parameter is false" do
      it "user can get a list of non-published papers" do
        paper1.update_attribute('published_at', 2.days.ago)
        get api_papers_path(published: false), nil, authorization: ActionController::HttpAuthentication::Token.encode_credentials(api_token)

        expect(JSON.parse(response.body)["authors"]).to be_empty
        expect(JSON.parse(response.body)["papers"]).to match_array([paper_json_attrs(paper2)])
      end
    end

    context "when the published parameter is true" do
      it "user can get a list of non-published papers" do
        paper1.update_attribute('published_at', 2.days.ago)
        get api_papers_path(published: true), nil, authorization: ActionController::HttpAuthentication::Token.encode_credentials(api_token)

        expect(JSON.parse(response.body)["authors"]).to match_array([author_json_attrs(author)])
        expect(JSON.parse(response.body)["papers"]).to match_array([paper_json_attrs(paper1)])
      end
    end

    context "when API token isn't provided" do
      it "returns a 401 not authorized status" do
        get api_papers_path
        expect(response.status).to eq(401)
      end
    end
  end

  describe "GET 'show'" do
    it "user can get a single paper" do
      get api_paper_path(paper1.id), nil, authorization: ActionController::HttpAuthentication::Token.encode_credentials(api_token)

      data = JSON.parse response.body
      expect(data['papers'].length).to eq 1
      expect(data["authors"]).to match_array([author_json_attrs(author)])
      expect(data["papers"]).to match_array([paper_json_attrs(paper1)])
    end

    it "user can get ePub for a single paper" do
      get api_paper_path(paper1.id, format: :epub), nil, authorization: ActionController::HttpAuthentication::Token.encode_credentials(api_token)
      expect(response.headers["Content-Type"]).to eq("application/epub+zip")
    end

    context "when API token isn't provided" do
      it "returns a 401 not authorized status" do
        get api_papers_path(paper1.id)
        expect(response.status).to eq(401)
      end
    end
  end

  describe "PATCH 'published_at'" do
    context "whitelisted attribute" do
      it "updates the published_at attribute for a paper" do
        patch_params = %Q{[{ "op": "replace", "path": "/papers/0/publishedAt", "value": "2014-03-21" }]}
        patch api_paper_path(paper1.id), patch_params, 'CONTENT_TYPE' => "application/json-patch+json",
          'ACCEPT' => "application/vnd.api+json",
          authorization: ActionController::HttpAuthentication::Token.encode_credentials(api_token)

        expect(response.body).to_not be_nil
        expect(response.status).to eq 204
        expect(paper1.reload.published_at).to eq("2014-03-21")
      end
    end

    context "non-whitelisted attribute" do
      it "does not update when attribute is not whitelisted for a paper" do
        patch_params = %Q{[{ "op": "replace", "path": "/papers/0/createdAt", "value": "2014-03-21" }]}
        patch api_paper_path(paper1.id), patch_params, 'CONTENT_TYPE' => "application/json-patch+json",
          'ACCEPT' => "application/vnd.api+json",
          authorization: ActionController::HttpAuthentication::Token.encode_credentials(api_token)

        expect(response.status).to eq 401
        expect(paper1.reload.created_at).to_not eq "2014-03-21"
      end
    end

    context "when API token isn't provided" do
      it "returns a 401 not authorized status" do
        patch_params = %Q([{ "op": "replace", "path": "/papers/0/publishedAt", "value": "2014-03-21" }])
        patch api_paper_path(paper1.id), patch_params, 'CONTENT_TYPE' => "application/json-patch+json",
          'ACCEPT' => "application/vnd.api+json"
        expect(response.status).to eq(401)
      end
    end
  end
end
