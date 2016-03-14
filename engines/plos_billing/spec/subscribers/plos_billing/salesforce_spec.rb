require 'rails_helper'

describe PlosBilling::Paper::Salesforce do
  let(:salesforce_manuscript_update_worker) do
    class_double(PlosBilling::SalesforceManuscriptUpdateWorker)
      .as_stubbed_const(transfer_nested_constants: true)
  end
  let(:user) { FactoryGirl.build_stubbed(:user) }
  let(:paper) { FactoryGirl.build_stubbed(:paper) }

  before do
    allow(Paper).to receive(:find).with(paper.id).and_return(paper)
    allow(paper).to receive(:creator) { user }
  end

  describe "subscribes to state changes" do
    before do
      expect(salesforce_manuscript_update_worker)
        .to receive(:perform_async).with(paper.id).once
    end

    it "finds or creates Salesforce Manuscript on submitted" do
      described_class.call("tahi:paper:submitted", record: paper)
    end

    it "finds or creates Salesforce Manuscript on accept" do
      described_class.call("tahi:paper:accepted", record: paper)
    end

    it "finds or creates Salesforce Manuscript on reject" do
      described_class.call("tahi:paper:rejected", record: paper)
    end

    it "finds or creates Salesforce Manuscript on withdraw" do
      described_class.call("tahi:paper:withdrawn", record: paper)
    end
  end
end
