require 'rails_helper'

describe EventBehavior do
  context 'when the action is send_email' do
    subject(:event_behavior) { build(:event_behavior, action: 'send_email') }

    it 'should fail validation unless a letter_template is set' do
      expect(subject).not_to be_valid
    end
  end
end
