require 'rails_helper'

describe Card do
  let(:card) { FactoryGirl.create(:card, :versioned) }

  context 'validation' do
    it 'is valid' do
      expect(card).to be_valid
    end
  end

  describe '#content_root_for_version' do
    it 'returns the root card content' do
      expect(card.content_root_for_version(1)).to be_present
    end
  end
end
