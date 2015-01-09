require 'rails_helper'

describe LitePapersController do

  let(:user) { create :user, :site_admin }
  let(:journal) { FactoryGirl.create(:journal) }
  let(:response_papers) { JSON.parse(response.body)['lite_papers'] }

  before { sign_in user }

  describe "#index" do
    let(:paper_count) { 20 }

    before do
      paper_count.times { FactoryGirl.create :paper, creator: user }
    end

    context "when there are less than 15" do
      let(:paper_count) { 10 }

      it "returns all papers" do
        get :index, format: :json, page_number: 1
        expect(response.status).to eq(200)
        expect(response_papers.count).to eq(paper_count)
      end
    end

    context "when there are more than 15" do
      let(:paper_count) { 20 }

      context "when page 1" do
        it "returns the first page of 15 papers" do
          get :index, page_number: 1, format: :json
          expect(response.status).to eq(200)
          expect(response_papers.count).to eq(15)
        end
      end

      context "when page 2" do
        it "returns the second page of 5 papers" do
          get :index, page_number: 2, format: :json
          expect(response.status).to eq(200)
          expect(response_papers.count).to eq(paper_count - 15)
        end
      end

      context "when page 3" do
        it "returns 0 papers" do
          get :index, page_number: 3, format: :json
          expect(response.status).to eq(200)
          expect(response_papers.count).to eq(0)
        end
      end
    end
  end
end
