require 'rails_helper'

describe Card do
  subject(:card) { FactoryGirl.build(:card) }

  context 'validation' do
    it 'is valid' do
      expect(card).to be_valid
    end
  end

  describe '#content_root' do
    let(:card) { FactoryGirl.create(:card) }
    let!(:card_content) { FactoryGirl.create(:card_content, card: card) }

    it 'returns the root card content' do
      expect(card.content_root).to eq(card_content)
    end

    it 'trying to create multiple card roots does not validate' do
      card_content = FactoryGirl.build(:card_content, card: card)
      expect(card_content).not_to be_valid
      expect(card_content.errors[:card]).to eq(["can only have a single root content."])
    end
  end
end
