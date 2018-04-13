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
require File.dirname(__FILE__) + '/sync_examples'

describe SalesforceServices::BillingSync do
  subject(:billing_sync) do
    described_class.new(paper: paper, salesforce_api: salesforce_api)
  end
  let(:paper) do
    instance_double(
      Paper,
      id: 99,
      billing_task: billing_task,
      salesforce_manuscript_id: 'abc123'
    )
  end
  let(:billing_task) { instance_double(PlosBilling::BillingTask) }
  let(:salesforce_api) { class_double(SalesforceServices::API) }

  before do
    allow_any_instance_of(FinancialDisclosureStatement).to receive(:asked?).and_return(true)
  end

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

    context 'without a financial disclosure summary' do
      before do
        allow_any_instance_of(FinancialDisclosureStatement).to receive(:asked?).and_return(false)
      end

      it 'requires financial disclosure question to be on the paper' do
        expect(billing_sync.valid?).to be(false)
        expect { billing_sync.sync! }.to raise_error.with_message(/financial disclosure does not exist/)
      end
    end
  end

  it_behaves_like 'salesforce sync object'

  describe '#sync!' do
    it 'ensures the PFA case exists in salesforce' do
      expect(salesforce_api).to receive(:ensure_pfa_case)
        .with(paper: paper)
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
