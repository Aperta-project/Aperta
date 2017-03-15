require 'rails_helper'

describe Card do
  let(:card) do
    FactoryGirl.create(
      :card,
      latest_version: 2
    )
  end
  let!(:old_version) { FactoryGirl.create(:card_version, card: card, version: 1) }
  let!(:new_version) { FactoryGirl.create(:card_version, card: card, version: 2) }

  context 'validation' do
    it 'is valid' do
      expect(card).to be_valid
    end
  end

  describe '#content_root_for_version' do
    it 'returns the root card content' do
      expect(card.content_root_for_version(1)).to be_present
    end

    it 'returns the root card content for the latest' do
      expect(card.content_root_for_version(:latest)).to be_present
    end
  end

  describe '#card_version' do
    it 'returns the card version with the specified number' do
      expect(card.card_version(1).version).to eq(1)
    end

    it 'returns the card version for the latest version' do
      expect(card.card_version(:latest).version).to eq(2)
    end
  end

  describe '#content_for_version' do
    it 'returns all card content for a given version' do
      old_version.content_root.children << FactoryGirl.create(:card_content)
      expect(card.content_for_version(1).count).to eq(2)
    end

    it 'returns all card content for the latest version' do
      new_version.content_root.children << FactoryGirl.create(:card_content)
      expect(card.content_for_version(:latest).count).to eq(2)
    end
  end

  describe '#content_for_version_without_root' do
    it 'returns all card content for a given version minus the root' do
      old_version.content_root.children << FactoryGirl.create(:card_content)
      expect(card.content_for_version_without_root(1).count).to eq(1)
      expect(card.content_for_version_without_root(1).first.parent_id).to be_present
    end

    it 'returns all card content for the latest version minus the root' do
      new_version.content_root.children << FactoryGirl.create(:card_content)
      expect(card.content_for_version_without_root(:latest).count).to eq(1)
      expect(card.content_for_version_without_root(:latest).first.parent_id).to be_present
    end
  end
end
