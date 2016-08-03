require 'rails_helper'

describe Paper::DecisionMade::UnassignReviewers do
  include EventStreamMatchers

  let!(:journal) do
    FactoryGirl.create :journal,
      :with_reviewer_role,
      :with_reviewer_report_owner_role,
      :with_task_participant_role
  end
  let(:paper) { FactoryGirl.create :paper, journal: journal }
  let(:task) { FactoryGirl.create :paper_reviewer_task, paper: paper }
  let!(:reviewer) { create :user }

  before do
    assign_reviewer_role paper, reviewer
  end

  it "unassigns reviewers" do
    expect(paper.reviewers.count).to eq(1)
    described_class.call("tahi:paper:withdrawn", record: paper)
    expect(paper.reviewers.count).to eq(0)
  end
end
