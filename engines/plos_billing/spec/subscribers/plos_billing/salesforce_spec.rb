require 'rails_helper'

describe PlosBilling::Paper::Submitted::Salesforce do
  let(:salesforce_manuscript_update_worker) do
    class_double(PlosBilling::SalesforceManuscriptUpdateWorker)
      .as_stubbed_const(transfer_nested_constants: true)
  end
  let(:user) { FactoryGirl.create(:user) }
  let(:paper) do
    FactoryGirl.create(:paper, :with_integration_journal, creator: user)
  end

  context "paper is submitted" do
    it "find or create Salesforce Manuscript" do
      expect(salesforce_manuscript_update_worker)
        .to receive(:perform_async).with(paper.id).once

      described_class.call("tahi:paper:submitted", record: paper)
    end
  end
end
