require 'rails_helper'

describe Card do
  subject(:card) { FactoryGirl.build(:card) }

  context 'validation' do
    it 'is valid' do
      expect(card).to be_valid
    end
  end
end
