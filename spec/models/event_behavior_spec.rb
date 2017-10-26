require 'rails_helper'

describe EventBehavior do
  describe '' do
    subject(:event_behavior) { create(:event_behavior) }

    it 'should be' do
      expect(event_behavior).to be
    end
  end
end
