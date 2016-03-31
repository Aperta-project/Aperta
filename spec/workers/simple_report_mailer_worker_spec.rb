require 'rails_helper'

describe SimpleReportMailerWorker do
  let(:simple_report) { double }
  let(:mailer) { double }

  it "builds a new report and mails it" do
    expect(SimpleReport).to receive(:build_new_report) { simple_report }
    expect(SimpleReportMailer).to receive(:send_report).with(simple_report).and_return(mailer)
    expect(mailer).to receive(:deliver_now)
    expect(simple_report).to receive(:save!)
    SimpleReportMailerWorker.new.perform
  end
end
