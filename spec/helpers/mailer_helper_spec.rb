require 'rails_helper'

describe MailerHelper do
  describe '#display_name' do
    let(:user) { FactoryGirl.build(:user) }

    it 'returns the full name if the full name is not blank' do
      user.first_name = "Aaron"
      user.last_name = "Baker"
      expect(display_name(user)).to eq("Aaron Baker")
    end

    it 'returns the username if the full name is blank' do
      user.first_name = nil
      user.last_name = nil
      expect(display_name(user)).to eq(user.username)
    end
  end
end
