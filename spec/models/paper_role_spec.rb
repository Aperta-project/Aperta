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

  describe "validations" do
    let(:paper) { FactoryGirl.create :paper, :with_tasks }

    context "when the role is in ALL_ROLES" do
      let(:user) { FactoryGirl.build(:user) }

      it "validates if the role is included in the ALL_ROLES list" do
        PaperRole::ALL_ROLES.each do |role|
          paper_role = PaperRole.new paper: paper,
            user: user,
            role: 'reviewer'
          expect(paper_role).to be_valid
        end
      end
    end

    context "when the role is not in ALL_ROLES" do
      let(:user) { FactoryGirl.build(:user) }

      it "validates if the role is included in the ALL_ROLES list" do
        PaperRole::ALL_ROLES.each do |role|
          paper_role = PaperRole.new paper: paper,
            user: user,
            role: 'not_any_role'
          expect(paper_role).to_not be_valid
        end
      end
    end
  end
end
