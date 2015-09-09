require 'rails_helper'

describe RegisterDecisionTask::Completed::ReportingEventLogger do

  let(:register_decision_task) { FactoryGirl.create(:register_decision_task, :with_decision) }

  it "creates a reporting event" do
    expect {
      described_class.call("tahi:tahi_standard_tasks/register_decision_task:completed", { record: register_decision_task })
    }.to change { ReportingEvent.count }.by(1)
  end

end
