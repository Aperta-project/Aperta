require 'rails_helper'

describe Paper::Resubmitted::ReopenRevisionTasks do
  include EventStreamMatchers

  let(:mailer) { mock_delayed_class(UserMailer) }
  let(:paper) { FactoryGirl.create(:paper) }
  let(:paper_reviewer_task) { FactoryGirl.create(:paper_reviewer_task, paper: paper, completed: true) }
  let(:register_decision_task) { FactoryGirl.create(:register_decision_task, paper: paper, completed: true) }

  it "marks all revision tasks as incomplete" do
    expect(paper_reviewer_task).to be_completed
    expect(register_decision_task).to be_completed
    described_class.call("tahi:paper:resubmitted", { paper: paper })
    expect(paper_reviewer_task.reload).to_not be_completed
    expect(register_decision_task.reload).to_not be_completed
  end

end
