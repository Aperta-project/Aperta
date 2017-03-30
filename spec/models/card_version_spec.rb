require 'rails_helper'

describe CardVersion do
  subject(:card_version) { FactoryGirl.create(:card_version) }

  context "#content_root" do
    it 'returns a root' do
      expect(card_version.content_root).to be
    end
  end
end
