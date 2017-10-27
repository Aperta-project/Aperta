require 'rails_helper'

describe EventBehavior do
  context 'when the action is send_email' do
    subject(:event_behavior) { build(:send_email_behavior) }

    it 'should fail validation unless a letter_template is set' do
      expect(subject).not_to be_valid
    end
  end
end
