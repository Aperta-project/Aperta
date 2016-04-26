require 'rails_helper'

describe SalesforceServices do
  describe '.sync_paper!' do
    subject(:sync_paper!) do
      SalesforceServices.sync_paper!(paper, logger: logger)
    end
    let(:paper) { instance_double(Paper, id: 99) }
    let(:logger) { Logger.new(StringIO.new) }

    context "when the paper's billing payment method is PFA" do
      before do
        allow(SalesforceServices::PaperSync).to receive(:sync!)
        allow(SalesforceServices::BillingSync).to receive(:sync!)
        allow(paper).to receive(:answer_for)
          .with('plos_billing--payment_method')
          .and_return instance_double(NestedQuestionAnswer, value: 'pfa')
      end

      it 'syncs the paper, then the billing information' do
        expect(SalesforceServices::PaperSync).to receive(:sync!)
          .with(paper: paper)
          .ordered
        expect(SalesforceServices::BillingSync).to receive(:sync!)
          .with(paper: paper)
          .ordered
        sync_paper!
      end

      it 'logs the sync was successful' do
        expect(logger).to receive(:info)
          .with("Salesforce: Paper #{paper.id} sync'd successfully")
          .ordered
        expect(logger).to receive(:info)
          .with("Salesforce: Billing info on Paper #{paper.id} sync'd successfully")
          .ordered
        sync_paper!
      end
    end

    context "when the paper's billing payment method exists, but is not PFA" do
      before do
        allow(SalesforceServices::PaperSync).to receive(:sync!)
        allow(paper).to receive(:answer_for)
          .with('plos_billing--payment_method')
          .and_return instance_double(NestedQuestionAnswer, value: 'not-pfa')
      end

      it 'syncs the paper, but not the billing information' do
        expect(SalesforceServices::PaperSync).to receive(:sync!)
        expect(SalesforceServices::BillingSync).to_not receive(:sync!)
        sync_paper!
      end

      it 'logs the billing sync was skipped' do
        expect(logger).to receive(:info)
          .with("Salesforce: Paper #{paper.id} sync'd successfully")
          .ordered
        expect(logger).to receive(:info)
          .with("Salesforce: Paper #{paper.id} is not PFA, skipping billing sync.")
          .ordered
        sync_paper!
      end
    end

    context 'when the paper is without a billing payment method' do
      before do
        allow(SalesforceServices::PaperSync).to receive(:sync!)
        allow(paper).to receive(:answer_for)
          .with('plos_billing--payment_method')
          .and_return nil
      end

      it 'syncs the paper, but not the billing information' do
        expect(SalesforceServices::PaperSync).to receive(:sync!)
        expect(SalesforceServices::BillingSync).to_not receive(:sync!)
        sync_paper!
      end

      it 'logs the sync was skipped' do
        expect(logger).to receive(:info)
          .with("Salesforce: Paper #{paper.id} sync'd successfully")
          .ordered
        expect(logger).to receive(:info)
          .with("Salesforce: Paper #{paper.id} is not PFA, skipping billing sync.")
          .ordered
        sync_paper!
      end
    end
  end
end
