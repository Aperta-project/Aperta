require 'rails_helper'

describe Paper::DecisionMade::InvalidateReviewerInvitations do
  include EventStreamMatchers

  let(:user) { FactoryGirl.create(:user) }
  let(:paper) { FactoryGirl.create(:paper) }
  let(:reviewer_task) { FactoryGirl.create(:paper_reviewer_task, paper: paper) }
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
