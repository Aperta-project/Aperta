require 'rails_helper'

shared_examples_for 'salesforce sync object' do
  describe '.sync!' do
    subject(:sync!) { described_class.sync!(paper: paper) }
    let(:paper) { instance_double(Paper) }

    let(:something_syncable) do
      instance_double(described_class, sync!: 'I was synced!')
    end

    it 'constructs a new sync, then tells it to sync!' do
      allow(described_class).to receive(:new)
        .with(paper: paper)
        .and_return something_syncable

      result = sync!
      expect(result).to eq('I was synced!')
    end
  end
end
