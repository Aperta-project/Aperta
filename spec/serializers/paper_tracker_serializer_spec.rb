require "rails_helper"

describe PaperTrackerSerializer, focus: true do
  describe "roles" do
    let(:user) { FactoryGirl.create :user }
    let(:paper) { FactoryGirl.create :paper, creator: user }

    context "there's a reviewer" do
      let!(:paper_role) { FactoryGirl.create :paper_role, :reviewer, paper: paper }
      let(:serialized_paper) do
        JSON.parse(PaperTrackerSerializer.new(paper).to_json,
                   symbolize_names: true)
      end

      it "returns " do
        roles = serialized_paper[:paper_tracker][:roles]
        reviewers = roles.find { |r| r[:role_name] == "reviewer" }[:users]

        expect(reviewers[0][:id]).to be(paper_role.user.id)
      end
    end
  end
end
