# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

require 'rails_helper'

describe SalesforceServices do
  describe '.sync_paper!' do
    around do |example|
      ClimateControl.modify SALESFORCE_ENABLED: 'true' do
        example.run
      end
    end

    subject(:sync_paper!) do
      SalesforceServices.sync_paper!(paper, logger: logger)
    end
    let(:paper) do
      instance_double(
        Paper,
        id: 99,
        latest_submitted_version: double("a submitted version")
      )
    end
    let(:logger) { Logger.new(StringIO.new) }

    context "when the paper has never been submitted" do
      before do
        allow(paper).to receive(:latest_submitted_version).and_return nil
      end

      it "doesn't sync the paper or its billing information" do
        expect(SalesforceServices::PaperSync).to_not receive(:sync!)
        expect(SalesforceServices::BillingSync).to_not receive(:sync!)
        sync_paper!
      end
    end

    context "when the paper's billing payment method is PFA" do
      before do
        allow(SalesforceServices::PaperSync).to receive(:sync!)
        allow(SalesforceServices::BillingSync).to receive(:sync!)
        allow(paper).to receive(:answer_for)
          .with('plos_billing--payment_method')
          .and_return instance_double(Answer, value: 'pfa')
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
          .and_return instance_double(Answer, value: 'not-pfa')
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
