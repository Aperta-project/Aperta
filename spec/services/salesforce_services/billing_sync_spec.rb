require 'rails_helper'

describe SalesforceServices::BillingSync do
  subject(:billing_sync) do
    described_class.new(paper: paper, salesforce_api: salesforce_api)
  end
  let(:paper) do
    instance_double(
      Paper,
      id: 99,
      billing_task: billing_task,
      financial_disclosure_task: financial_disclosure_task,
      salesforce_manuscript_id: 'abc123'
    )
  end
  let(:billing_task) { instance_double(PlosBilling::BillingTask) }
  let(:financial_disclosure_task) do
    instance_double(TahiStandardTasks::FinancialDisclosureTask)
  end
  let(:salesforce_api) { class_double(SalesforceServices::API) }

  describe 'validations' do
    it { is_expected.to be_valid }

    it 'requires a paper' do
      billing_sync.paper = nil
      expect(billing_sync.valid?).to be(false)
    end

    it 'requires the paper has been syncd to salesforce before' do
      allow(paper).to receive(:salesforce_manuscript_id).and_return nil
      expect(billing_sync.valid?).to be(false)
    end

    it 'requires a billing task' do
      allow(paper).to receive(:billing_task).and_return nil
      expect(billing_sync.valid?).to be(false)
    end

    it 'requires a financial disclosure task' do
      allow(paper).to receive(:financial_disclosure_task).and_return nil
      expect(billing_sync.valid?).to be(false)
    end
  end

  describe '#sync!' do
    it 'ensures the PFA case exists in salesforce' do
      expect(salesforce_api).to receive(:ensure_pfa_case)
        .with(paper_id: paper.id)
      billing_sync.sync!
    end

    context 'when the billing_sync is not valid' do
      it 'raises an error communicating why its not valid' do
        billing_sync.paper = nil
        expect do
          billing_sync.sync!
        end.to raise_error(
          SalesforceServices::SyncInvalid,
          /The paper's billing information cannot be sent to Salesforce/m
        )
      end
    end
  end
end
