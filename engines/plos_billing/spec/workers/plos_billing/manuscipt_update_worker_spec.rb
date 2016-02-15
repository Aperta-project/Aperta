require "rails_helper"

describe PlosBilling::ManuscriptUpdateWorker do
  describe "#email_admin_on_error" do
    let(:dbl) { double }
    let(:msg) do
      {
        "class" => "SomeClass",
        "args" => [4],
        "error_message" => "some message"
      }
    end
    let(:error_message) do
      "Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}"
    end

    it "calls BillingSalesforceMailer" do
      expect(PlosBilling::BillingSalesforceMailer).to receive(:delay) { dbl }
      expect(dbl).to receive(:notify_journal_admin_sfdc_error)
        .with(4, error_message)
      PlosBilling::ManuscriptUpdateWorker.email_admin_on_error(msg)
    end
  end
end
