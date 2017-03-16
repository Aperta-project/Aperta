require 'rails_helper'

describe VersionCardContent do
  describe "save_new_version" do
    let!(:card) { FactoryGirl.create(:card, :versioned, latest_version: 1) }

    it "increments the card's latest version" do
      VersionCardContent.save_new_version(card, "text" => "new text")
      expect(card.reload.latest_version).to eq(2)
    end

    it "creates a new CardVersion with a higher version number" do
      VersionCardContent.save_new_version(card, "text" => "new text")
      expect(CardVersion.last.version).to eq(2)
    end

    it "leaves the previous CardVersion and content around" do
      CardContent.last.update(text: "old text")
      VersionCardContent.save_new_version(card, "text" => "new text")

      expect(card.card_versions.count).to eq(2)
      expect(CardContent.where(card: card).count).to eq(2)
      expect(CardVersion.last.card_content.text).to eq("new text")
    end
  end
end
