require 'rails_helper'

describe CardContent do
  subject(:card_content) { FactoryGirl.build(:card_content) }

  context 'validation' do
    it 'is valid' do
      expect(card_content).to be_valid
    end
  end

  context "root scope" do
    let!(:root_content) { FactoryGirl.create(:card_content, parent: nil) }

    it 'returns all roots' do
      expect(CardContent.all.root.id).to be(root_content.id)
    end
  end
end
