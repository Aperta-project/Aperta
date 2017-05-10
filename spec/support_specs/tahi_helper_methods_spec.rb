require "rails_helper"

describe TahiHelperMethods do
  describe "::register_paper_decision" do
    let(:paper) { create :paper, :submitted_lite }
    subject(:register) { -> { register_paper_decision(paper, "minor_revision") } }
    let(:decision) { paper.draft_decision }

    it { is_expected.to change { paper.publishing_state }.from("submitted").to("in_revision") }
  end
end
