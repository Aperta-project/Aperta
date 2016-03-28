require 'rails_helper'

describe SalesforceServices do
  describe '.sync_paper!' do
    subject(:sync_paper!) { SalesforceServices.sync_paper!(paper) }
    let(:paper) { instance_double(Paper) }

    context "when the paper's billing payment method is PFA" do
      before do
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
    end

    context "when the paper's billing payment method exists, but is not PFA" do
      before do
        allow(paper).to receive(:answer_for)
          .with('plos_billing--payment_method')
          .and_return instance_double(NestedQuestionAnswer, value: 'not-pfa')
      end

      it 'does not sync the paper nor the billing information' do
        expect(SalesforceServices::PaperSync).to_not receive(:sync!)
        expect(SalesforceServices::BillingSync).to_not receive(:sync!)
        sync_paper!
      end
    end

    context 'when the paper is without a billing payment method' do
      before do
        allow(paper).to receive(:answer_for)
          .with('plos_billing--payment_method')
          .and_return nil
      end

      it 'does not sync the paper nor the billing information' do
        expect(SalesforceServices::PaperSync).to_not receive(:sync!)
        expect(SalesforceServices::BillingSync).to_not receive(:sync!)
        sync_paper!
      end
    end
  end
end
