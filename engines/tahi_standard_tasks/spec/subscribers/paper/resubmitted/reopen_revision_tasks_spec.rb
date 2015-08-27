require 'rails_helper'

describe Paper::Resubmitted::ReopenRevisionTasks do
  include EventStreamMatchers

  let(:mailer) { mock_delayed_class(UserMailer) }
  let(:paper) { FactoryGirl.create(:paper) }
  let(:paper_reviewer_task) { FactoryGirl.create(:paper_reviewer_task, paper: paper, complete: true) }
  let(:register_decision_task) { FactoryGirl.create(:register_decision_task, paper: paper, complete: true) }

  it "marks all revision tasks as incomplete" do
    expect(paper_reviewer_task).to be_complete
    expect(register_decision_task).to be_complete
    described_class.call("tahi:paper:resubmitted", { paper: paper })
    expect(paper_reviewer_task).to_not be_complete
    expect(register_decision_task).to_not be_complete
  end

end
