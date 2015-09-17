require 'rails_helper'

describe Paper::Submitted::ReportingEventLogger do

  let(:paper) { FactoryGirl.create(:paper) }

  it "creates a reporting event" do
    expect {
      described_class.call("tahi:paper:submitted", { record: paper })
    }.to change { ReportingEvent.count }.by(1)
  end

end
