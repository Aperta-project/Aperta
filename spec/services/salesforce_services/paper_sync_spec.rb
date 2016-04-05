require 'rails_helper'
require File.dirname(__FILE__) + '/sync_examples'

describe SalesforceServices::PaperSync do
  subject(:paper_sync) do
    described_class.new(paper: paper, salesforce_api: salesforce_api)
  end
  let(:paper) { instance_double(Paper, id: 99) }
  let(:salesforce_api) { class_double(SalesforceServices::API) }

  describe 'validations' do
    it { is_expected.to be_valid }

    it 'requires a paper' do
      paper_sync.paper = nil
      expect(paper_sync.valid?).to be(false)
    end
  end

  it_behaves_like 'salesforce sync object'

  describe '#sync!' do
    it 'finds or creates the corresponding manuscript in salesforce' do
      expect(salesforce_api).to receive(:find_or_create_manuscript)
        .with(paper: paper)
      paper_sync.sync!
    end

    context 'when the paper_sync is not valid' do
      it 'raises an error communicating why its not valid' do
        paper_sync.paper = nil
        expect do
          paper_sync.sync!
        end.to raise_error(
          SalesforceServices::SyncInvalid,
          /The paper cannot be sent to Salesforce.*Paper can't be blank/m
        )
      end
    end
  end
end
