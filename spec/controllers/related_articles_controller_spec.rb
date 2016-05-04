require 'rails_helper'

describe RelatedArticlesController do
  let(:user) { FactoryGirl.create(:user) }
  let!(:related_article) { FactoryGirl.create(:related_article, paper: paper) }
  let(:paper) { FactoryGirl.create(:paper) }
  let(:post_request) do
    post :create,
         format: :json,
         related_article: {
           additional_info: "This is a paper I picked at random from the internet",
           linked_doi: "journal.pcbi.1004816",
           linked_title: "The best linked article in texas",
           send_link_to_apex: true,
           send_manuscripts_together: false,
           paper_id: paper.id
         }
  end
  let(:delete_request) { delete :destroy, format: :json, id: related_article.id }
  let(:put_request) do
    put :update,
        format: :json,
        id: related_article.id,
        related_article: { additional_info: "Neat!" }
  end

  before do
    allow(request.env['warden']).to receive(:authenticate!).and_return(user)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe "when the current user can edit_authors on the paper" do
    before do
      allow(user).to receive(:can?).with(:edit_related_articles, paper).and_return(true)
    end

    it 'a POST request creates a new author' do
      expect { post_request }.to change { RelatedArticle.count }.by(1)
    end

    it 'a PUT request updates the author' do
      put_request
      expect(related_article.reload.additional_info).to eq "Neat!"
    end

    it 'a DELETE request deletes the author' do
      expect { delete_request }.to change { RelatedArticle.count }.by(-1)
    end
  end

  describe "when the current user can NOT edit_authors on the paper" do
    before do
      allow(user).to receive(:can?).with(:edit_related_articles, paper).and_return(false)
    end

    it 'a POST request does not create a new author' do
      expect { post_request }.not_to change { RelatedArticle.count }
    end

    it 'a PUT request does not update an author' do
      put_request
      expect(related_article.reload.additional_info).not_to eq "Neat!"
    end

    it 'a DELETE request does not delete an author' do
      expect { delete_request }.not_to change { RelatedArticle.count }
    end

    it 'a POST request responds with a 403' do
      post_request
      expect(response).to have_http_status(:forbidden)
    end

    it 'a PUT request responds with a 403' do
      put_request
      expect(response).to have_http_status(:forbidden)
    end

    it 'a DELETE request responds with a 403' do
      delete_request
      expect(response).to have_http_status(:forbidden)
    end
  end
end
