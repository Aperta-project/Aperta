require 'rails_helper'

describe TahiStandardTasks::ApexDelivery do
  subject(:apex_delivery) { FactoryGirl.build(:apex_delivery) }

  describe 'validations' do
    it 'is valid' do
      expect(apex_delivery.valid?).to be(true)
    end

    it 'requires a user' do
      apex_delivery.user = nil
      expect(apex_delivery.valid?).to be(false)
    end

    it 'requires a paper' do
      apex_delivery.paper = nil
      expect(apex_delivery.valid?).to be(false)
    end

    it 'requires a task' do
      apex_delivery.task = nil
      expect(apex_delivery.valid?).to be(false)
    end
  end
end
