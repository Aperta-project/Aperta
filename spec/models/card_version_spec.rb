require 'rails_helper'

describe CardVersion do
  subject(:card_version) { FactoryGirl.create(:card_version) }

  describe "validations" do
    context "#submittable_state" do
      it "is invalid if workflow display only, but required for submission" do
        card_version = FactoryGirl.build(:card_version,
                          workflow_display_only: true,
                          required_for_submission: true)
        expect(card_version).to be_invalid
      end
    end
  end

  context "#content_root" do
    it 'returns a root' do
      expect(card_version.content_root).to be
    end
  end
end
