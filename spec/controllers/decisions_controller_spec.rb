require 'rails_helper'

describe DecisionsController do
  let(:user) { FactoryGirl.create(:user, :site_admin) }
  let(:paper) do
    FactoryGirl.create(:paper, :with_integration_journal, creator: user)
  end

  before do
    paper.decisions.destroy_all # force remove Paper's Decisions for testing
    sign_in user
  end

  describe "#create" do
    before do
      post :create, decision: { paper_id: paper.id }
    end

    it "assigns @paper" do
      expect(assigns(:paper)).to eq paper
    end

    it "assigns @decision" do
      expect(assigns(:decision).class).to eq Decision
      expect(assigns(:decision).revision_number).to eq 0
    end
  end

  describe "#update" do
    let(:new_letter) { "Positive Words in a Letter" }
    let(:new_verdict) { "accepted" }

    before do
      paper.decisions.create!
      paper.reload

      put :update,
        id: paper.decisions.latest.id,
        decision: {
          letter: new_letter,
          verdict: new_verdict,
          revision_number: 99,
          format: :json
        }
    end

    context "assigns @decision" do
      it "updates letter and verdict" do
        expect(assigns(:decision).letter).to eq new_letter
        expect(assigns(:decision).verdict).to eq new_verdict
      end

      it "does not update revision_number" do
        expect(assigns(:decision).revision_number).to_not eq 99
        expect(assigns(:decision).revision_number).to eq 0
      end
    end
  end
end
