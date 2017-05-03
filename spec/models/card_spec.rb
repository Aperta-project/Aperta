require 'rails_helper'

describe Card do
  let(:card) do
    FactoryGirl.create(
      :card,
      :versioned
    )
  end

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

  describe 'create_published!' do
    let(:new_card) { Card.create_published!(name: 'foo') }
    it 'creates a new card with the given attributes' do
      expect(new_card.name).to eq('foo')
    end

    it 'creates a new published card version' do
      expect(new_card.latest_card_version).to be_published
      expect(new_card.latest_card_version).to eq(new_card.latest_published_card_version)
    end

    it 'gives the card version a piece of card content' do
      expect(new_card.latest_card_version.content_root).to be_present
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

  describe "#publish!" do
    let(:card) do
      FactoryGirl.create(
        :card,
        latest_version: 1
      )
    end
    let!(:card_version) do
      FactoryGirl.create(
        :card_version,
        card: card,
        version: 1,
        published_at: nil
      )
    end

    it "sets the published_at on the latest version if it's unset" do
      card.publish!
      expect(card_version.reload.published_at).to be_present
    end

    it "blows up if the latest version is already published" do
      card_version.update(published_at: Time.current)
      expect { card.publish! }.to raise_exception AASM::InvalidTransition
    end
  end

  context "a card with multiple versions" do
    let(:card) do
      FactoryGirl.create(
        :card,
        latest_version: 2
      )
    end
    let!(:old_version) { FactoryGirl.create(:card_version, card: card, version: 1) }
    let!(:new_version) { FactoryGirl.create(:card_version, card: card, version: 2) }
    describe '#card_version' do
      it 'returns the card version with the specified number' do
        expect(card.card_version(1).version).to eq(1)
      end

      it 'returns the card version for the latest version' do
        expect(card.latest_card_version.version).to eq(2)
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

  # For now the real meat of the tests are with the XmlCardLoader
  describe "#update_from_xml" do
    let(:card) do
      FactoryGirl.create(
        :card,
        :versioned
      )
    end
    context "the card is published" do
      it "has the XmlCardLoader make a new draft version" do
        allow(XmlCardLoader).to receive(:new_version_from_xml_string)
        expect(XmlCardLoader).to receive(:new_version_from_xml_string).with("foo", card)
        card.update_from_xml("foo")
      end
    end

    context "the card is a draft" do
      it "has the XmlCardLoader replace the current draft" do
        card.update(state: "draft")
        card.latest_card_version.update(published_at: nil)
        allow(XmlCardLoader).to receive(:replace_draft_from_xml_string)
        expect(XmlCardLoader).to receive(:replace_draft_from_xml_string).with("foo", card)
        card.update_from_xml("foo")
      end
    end

    context "the card is published with changes" do
      it "has the XmlCardLoader replace the current draft" do
        card.update(state: "published_with_changes")
        card.latest_card_version.update(published_at: nil)
        allow(XmlCardLoader).to receive(:replace_draft_from_xml_string)
        expect(XmlCardLoader).to receive(:replace_draft_from_xml_string).with("foo", card)
        card.update_from_xml("foo")
      end
    end
  end
end
