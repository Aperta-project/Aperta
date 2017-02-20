require 'rails_helper'

describe Answer do
  subject(:answer) { FactoryGirl.build(:answer, :with_task_owner) }

  context 'validation' do
    it 'is valid' do
      expect(answer).to be_valid
    end
  end
end
