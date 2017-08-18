require 'rails_helper'

describe Permission do
  describe ".non_custom_card" do
    let(:card) { FactoryGirl.create(:card) }

    let!(:non_card_permission) { FactoryGirl.create(:permission) }
    let!(:card_permission) { FactoryGirl.create(:permission, filter_by_card_id: card.id) }

    it "only returns permissions that are not tied to cards" do
      expect(Permission.non_custom_card).to contain_exactly(non_card_permission)
    end
  end
end
