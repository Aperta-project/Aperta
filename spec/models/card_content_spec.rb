require 'rails_helper'

describe CardContent do
  subject(:card_content) { FactoryGirl.build(:card_content) }

  context 'validation' do
    it 'is valid' do
      expect(card_content).to be_valid
    end
  end
end
