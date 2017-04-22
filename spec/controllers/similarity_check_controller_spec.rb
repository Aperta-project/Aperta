require 'rails_helper'

describe SimilarityChecksController, type: :controller do
  describe "#create" do
    let!(:versioned_text) { create :versioned_text }
    let(:do_request) do
      get :create, format: :json, similarity_check: {
        versioned_text_id: versioned_text.to_param
      }
    end
    let(:user) { create :user }

    context "the user can perform a similarity check" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
                         .with(:perform_similarity_check, versioned_text.paper)
                         .and_return true
      end

      it "succeeds" do
        do_request
        expect(response).to be_success
      end

      it "creates a new SimilarityCheck record" do
        expect do
          do_request
        end.to change { SimilarityCheck.count }.by(1)
      end
    end

    context "the user can't perform similarity checks" do
      before do
        stub_sign_in user
      end

      it "fails with an HTTP 403" do
        do_request
        expect(response.status).to eq 403
      end

      it "does not create a SimilarityCheck record" do
        expect do
          do_request
        end.to_not change { SimilarityCheck.count }
      end
    end
  end
end
