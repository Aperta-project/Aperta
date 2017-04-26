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

    it 'enforces a unique name per journal' do
      journal_a =  FactoryGirl.create(:journal)
      journal_b =  FactoryGirl.create(:journal)
      FactoryGirl.create(:card, name: "Foo", journal: journal_a)
      new_invalid_card = FactoryGirl.build(:card, name: "Foo", journal: journal_a)
      expect(new_invalid_card).to_not be_valid
      expect(new_invalid_card.errors[:name]).to be_present

      new_valid_card = FactoryGirl.build(:card, name: "Foo", journal: journal_b)
      expect(new_valid_card).to be_valid
    end
  end

  describe 'create_new!' do
    let(:new_card) { Card.create_new!(name: 'foo') }
    it 'creates a new card with the given attributes' do
      expect(new_card.name).to eq('foo')
    end

    it 'creates a new card version' do
      expect(new_card.card_version(:latest)).to be_present
    end

    it 'gives the card version a piece of card content' do
      expect(new_card.card_version(:latest).content_root).to be_present
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

  describe '.find_by_class_name' do
    let(:card) { FactoryGirl.create(:card, journal: nil) }
    let(:card_class_name) { "A::Sample::ClassName" }

    context 'with successful namespace lookup' do
      before do
        expect(LookupClassNamespace).to receive(:lookup_namespace)
                                    .with(card_class_name)
                                    .and_return(card.name)
      end

      it 'finds the card' do
        expect(Card.find_by_class_name(card_class_name)).to eq(card)
      end
    end

    context 'without successful namespace lookup' do
      it 'returns nil' do
        expect(Card.find_by_class_name(card_class_name)).to be_nil
      end
    end
  end

  describe '.find_by_class_name!' do
    let(:card) { FactoryGirl.create(:card, journal: nil) }
    let(:card_class_name) { "A::Sample::ClassName" }

    context 'with successful namespace lookup' do
      before do
        expect(LookupClassNamespace).to receive(:lookup_namespace)
                                    .with(card_class_name)
                                    .and_return(card.name)
      end

      it 'finds the card' do
        expect(Card.find_by_class_name!(card_class_name)).to eq(card)
      end
    end

    context 'without successful namespace lookup' do
      it 'raises an error' do
        expect do
          Card.find_by_class_name!(card_class_name)
        end.to raise_error(ActiveRecord::RecordNotFound, /#{card_class_name}/)
      end
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
