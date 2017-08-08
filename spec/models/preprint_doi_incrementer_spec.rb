require 'rails_helper'

describe Card do
  let(:incrementer) { PreprintDoiIncrementer.create }

  describe '#succ!' do
    it 'increments the singletons value by one' do
      start_value = incrementer.value
      incrementer.succ!
      expect(incrementer.value).to eq(start_value + 1)
      incrementer.succ!
      expect(incrementer.value).to eq(start_value + 2)
    end
  end

  describe '#to_s' do
    it 'creates a 7 digit string from the value with leading zeros' do
      incrementer.value = 1
      expect(incrementer.to_doi).to eq("0000001")
      incrementer.value = 46
      expect(incrementer.to_doi).to eq("0000046")
      incrementer.value = 397
      expect(incrementer.to_doi).to eq("0000397")
      incrementer.value = 4890
      expect(incrementer.to_doi).to eq("0004890")
      incrementer.value = 34908
      expect(incrementer.to_doi).to eq("0034908")
      incrementer.value = 129362
      expect(incrementer.to_doi).to eq("0129362")
      incrementer.value = 2349087
      expect(incrementer.to_doi).to eq("2349087")
    end
  end
end
