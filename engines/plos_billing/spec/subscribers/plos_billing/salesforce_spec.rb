require 'rails_helper'

describe PlosBilling::Paper::Submitted::Salesforce do
  let(:salesforce_api) { mock_delayed_class(SalesforceServices::API) }
  let(:user) { FactoryGirl.create(:user) }

  context "paper without a billing task" do
    let(:paper) do
      FactoryGirl.create(:paper, :with_integration_journal, creator: user)
    end

    it "find or create Salesforce Manuscript" do
      expect(salesforce_api).to receive(:find_or_create_manuscript).with(paper_id: paper.id).once

      described_class.call("tahi:paper:submitted", record: paper)
    end
  end

  context "paper with a billing task" do
    let(:paper_with_task) {
      FactoryGirl.create :paper_with_task, task_params: { title: "Billing", type: "PlosBilling::BillingTask", old_role: "author" }
    }

    it "find or create Salesforce Manuscript and create Case" do
      expect(salesforce_api).to receive(:find_or_create_manuscript).with(paper_id: paper_with_task.id).once
      expect(salesforce_api).to receive(:create_billing_and_pfa_case).with(paper_id: paper_with_task.id).once

      described_class.call("tahi:paper:submitted", record: paper_with_task)
    end
  end
end
