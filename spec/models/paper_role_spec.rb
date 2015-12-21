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
    let(:user) { FactoryGirl.build(:user) }

    context "when the old_role is in ALL_ROLES" do
      it "validates if the old_role is included in the ALL_ROLES list" do
        PaperRole::ALL_ROLES.each do |old_role|
          paper_role = PaperRole.new paper: paper,
            user: user,
            old_role: 'reviewer'
          expect(paper_role).to be_valid
        end
      end
    end

    context "when the old_role is one of the journal old_roles" do
      before do
        OldRole.create! name: "clean_coder", journal: paper.journal
        paper.journal.old_roles.reload
      end

      it "validates if the old_role is included in the ALL_ROLES list" do
        paper_role = PaperRole.new paper: paper,
          user: user,
          old_role: 'clean_coder'
        expect(paper_role).to be_valid
      end
    end

    context "when the old_role is not in ALL_ROLES" do

      it "validates if the old_role is included in the ALL_ROLES list" do
        PaperRole::ALL_ROLES.each do |old_role|
          paper_role = PaperRole.new paper: paper,
            user: user,
            old_role: 'not_any_role'
          expect(paper_role).to_not be_valid
        end
      end
    end
  end
end
