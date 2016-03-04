require 'rails_helper'

describe SalesforceServices do
  describe 'send_to_salesforce?' do
    subject { SalesforceServices.send_to_salesforce?(paper: paper) }
    let(:paper) { FactoryGirl.create(:paper) }

    context 'without billing card' do
      it 'raises BillingCardMissing' do
        expect { subject }
          .to raise_error SalesforceServices::BillingCardMissing
      end
    end

    context 'with billing card' do
      before do
        billing_card = double(:billing_card)
        allow(paper).to receive(:billing_card) { billing_card }
        expect(billing_card)
          .to receive(:answer_for)
          .with("plos_billing--payment_method")
          .and_return(answer)
      end

      context 'no payment method' do
        let(:answer) { nil }

        it 'raises BillingFundingSourceMissing' do
          expect { subject }
            .to raise_error SalesforceServices::BillingFundingSourceMissing
        end
      end

      context 'non pfa payment method' do
        let(:answer) { OpenStruct.new(value: 'something else') }

        it 'is false' do
          expect(subject).to eq(false)
        end
      end

      context 'pfa payment method' do
        let(:answer) { OpenStruct.new(value: 'pfa') }

        it 'is true' do
          expect(subject).to eq(true)
        end
      end
    end
  end
end
