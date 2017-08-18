require 'rails_helper'

describe PreprintDoiIncrementer do
  let(:incrementer) { PreprintDoiIncrementer.create }

  describe '#succ!' do
    it 'increments the singletons value by one' do
      start_value = incrementer.value
      incrementer.send(:succ!)
      expect(incrementer.value).to eq(start_value + 1)
      incrementer.send(:succ!)
      expect(incrementer.value).to eq(start_value + 2)
    end
  end

  describe '#to_doi' do
    it 'creates a 7 digit string from the value with leading zeros' do
      incrementer.value = 1
      expect(incrementer.send(:to_doi)).to eq("0000001")
      incrementer.value = 46
      expect(incrementer.send(:to_doi)).to eq("0000046")
      incrementer.value = 397
      expect(incrementer.send(:to_doi)).to eq("0000397")
      incrementer.value = 4890
      expect(incrementer.send(:to_doi)).to eq("0004890")
      incrementer.value = 34_908
      expect(incrementer.send(:to_doi)).to eq("0034908")
      incrementer.value = 129_362
      expect(incrementer.send(:to_doi)).to eq("0129362")
      incrementer.value = 2_349_087
      expect(incrementer.send(:to_doi)).to eq("2349087")
    end
  end
end
