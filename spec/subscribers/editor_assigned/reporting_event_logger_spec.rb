require 'rails_helper'

describe EditorAssigned::ReportingEventLogger do

  let(:task) { FactoryGirl.create(:task) }

  it "creates a reporting event" do
    expect {
      described_class.call("tahi:task:completed", { record: task })
    }.to change { ReportingEvent.count }.by(1)
  end

end
