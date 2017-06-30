require 'rails_helper'

describe SimpleReportMailerWorker do
  let(:simple_report) { double }

  it "builds a new report and mails it" do
    expect(SimpleReport).to receive(:build_new_report) { simple_report }
    expect(simple_report).to receive(:save!)
    SimpleReportMailerWorker.new.perform
  end
end
