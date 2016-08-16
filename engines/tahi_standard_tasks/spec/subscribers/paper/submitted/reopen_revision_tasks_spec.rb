require 'rails_helper'

describe Paper::Submitted::ReopenRevisionTasks do
  include EventStreamMatchers

  let(:mailer) { mock_delayed_class(UserMailer) }
  let(:paper) { FactoryGirl.create(:paper) }
  let(:paper_reviewer_task) do
    FactoryGirl.create(:paper_reviewer_task, paper: paper, completed: true)
  end
  let(:register_decision_task) do
    FactoryGirl.create(:register_decision_task, paper: paper, completed: true)
  end

  it "marks all revision tasks as incomplete" do
    expect(paper_reviewer_task).to be_completed
    expect(register_decision_task).to be_completed
    described_class.call("tahi:paper:submitted", record: paper)
    expect(paper_reviewer_task.reload).to_not be_completed
    expect(register_decision_task.reload).to_not be_completed
  end
end
