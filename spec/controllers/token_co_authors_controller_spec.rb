require "rails_helper"

describe TokenCoAuthorsController do
  let(:author) { FactoryGirl.create(:author) }

  describe 'GET /co_authors_token/:token' do
    subject(:do_request) { get :show, token: author.token }
    it "renders the show template" do
      do_request
      expect(response).to render_template("token_co_authors/show")
    end

    context "author previously confirmed" do
      let!(:author) { FactoryGirl.create(:author, co_author_state: 'confirmed') }
      it "redirects to #thank_you" do
        do_request
        expect(response).to redirect_to(:thank_you_token_co_author)
      end
    end
  end

  describe "PUT /co_authors_token/:token/confirm" do
    subject(:do_request) { put :confirm, token: author.token }
    it "confirms the author as a co author" do
      expect { do_request }.to change {
        author.reload
        author.co_author_confirmed?
      }
    end

    it "creates an activity feed item" do
      expect(Activity).to receive(:co_author_confirmed!).with(author, user: nil)
      do_request
    end

    it "redirects to #thank_you" do
      do_request
      expect(response).to redirect_to(:thank_you_token_co_author)
    end

    context "author previously confirmed" do
      let!(:author) { FactoryGirl.create(:author, co_author_state: 'confirmed') }
      it "redirects to #thank_you" do
        do_request
        expect(response).to redirect_to(:thank_you_token_co_author)
      end
    end
  end

  describe "GET /co_authors_token/:token/thank_you" do
    let!(:author) { FactoryGirl.create(:author, co_author_state: 'confirmed') }
    subject(:do_request) { get :thank_you, token: author.token }
    it "renders the thank you template" do
      do_request
      expect(response).to render_template("token_co_authors/thank_you")
    end

    describe "author is not confirmed" do
      let!(:author) { FactoryGirl.create(:author) }

      it "redirects to #show" do
        do_request
        expect(response).to redirect_to(:show_token_co_author)
      end
    end
  end
end
