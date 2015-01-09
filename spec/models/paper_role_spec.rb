require 'rails_helper'

describe PaperRole do
  let(:paper) { FactoryGirl.create :paper, :with_tasks }
  describe "scopes" do
    describe "reviewers_for" do
      let(:user) { FactoryGirl.build(:user) }
      it "returns reviewers for a given paper" do
        reviewer_paper_role = create(:paper_role, :reviewer, paper: paper, user: user)
        other_paper_role = create(:paper_role, :editor, paper: paper, user: user)

        expect(PaperRole.reviewers_for(paper)).to_not include other_paper_role
        expect(PaperRole.reviewers_for(paper)).to include reviewer_paper_role
      end
    end
  end
end
