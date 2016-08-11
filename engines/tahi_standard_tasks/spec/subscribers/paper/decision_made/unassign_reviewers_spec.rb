require 'rails_helper'

describe Paper::DecisionMade::UnassignReviewers do
  include EventStreamMatchers

  context "rescinding invites" do
    let(:user) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create(:paper) }
    let(:reviewer_task) do
      FactoryGirl.create(:paper_reviewer_task, paper: paper)
    end
    let!(:invitation) do
      FactoryGirl.create(:invitation, :invited, task: reviewer_task)
    end

    it "rescinds the invitations" do
      expect(reviewer_task.invitations.where(state: "invited").count).to eq(1)
      described_class.call("tahi:paper:withdrawn", record: paper)
      reviewer_task.reload
      expect(reviewer_task.invitations.where(state: "invited").count).to eq(0)
    end
  end

  context "unassigning reviewers from the paper" do
    let!(:journal) do
      FactoryGirl.create :journal,
        :with_reviewer_role,
        :with_reviewer_report_owner_role,
        :with_task_participant_role
    end
    let(:paper) { FactoryGirl.create :paper, journal: journal }
    let(:task) { FactoryGirl.create :paper_reviewer_task, paper: paper }
    let(:reviewer_report_task) do
      FactoryGirl.create :reviewer_report_task, paper: paper
    end
    let!(:reviewer) { create :user }

    before do
      assign_reviewer_role paper, reviewer
      assign_task_participant_role reviewer_report_task, reviewer
    end

    it "unassigns reviewers from the paper" do
      expect(paper.reviewers.count).to eq(1)
      described_class.call("tahi:paper:withdrawn", record: paper)
      expect(paper.reviewers.count).to eq(0)
    end

    it "unassigns reviewers as participants from their reviewer report tasks" do
      described_class.call("tahi:paper:withdrawn", record: paper)
      assignments = Assignment.where(user: reviewer,
                                     assigned_to: reviewer_report_task,
                                     role: journal.task_participant_role)
      expect(assignments).to eq([])
    end
  end
end
