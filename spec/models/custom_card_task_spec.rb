require 'rails_helper'

describe CustomCardTask do
  it 'is valid with factory defaults' do
    custom_card_task = FactoryGirl.build(:custom_card_task)
    expect(custom_card_task).to be_valid
  end
end
