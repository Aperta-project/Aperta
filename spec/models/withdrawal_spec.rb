require 'rails_helper'

describe Withdrawal do
  describe '.most_recent' do
    let!(:withdrawal_1) { FactoryGirl.create(:withdrawal) }
    let!(:withdrawal_2) { FactoryGirl.create(:withdrawal) }
    let!(:withdrawal_3) { FactoryGirl.create(:withdrawal) }

    it 'returns the most recent withdrawal' do
      expect(Withdrawal.most_recent).to eq withdrawal_3
    end
  end
end
