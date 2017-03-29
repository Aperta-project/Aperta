require 'rails_helper'

describe TaskTemplate do
  describe 'custom validations' do
    describe 'card relationships' do
      let(:card) { FactoryGirl.create(:card) }
      let(:journal_task_type) { FactoryGirl.create(:journal_task_type) }

      it 'is invalid if associated to both a card and journal task type' do
        task_template = FactoryGirl.build(:task_template, card: card, journal_task_type: journal_task_type)
        expect(task_template).to be_invalid
      end

      it 'is invalid if associated to neither a card nor journal task type' do
        task_template = FactoryGirl.build(:task_template, card: nil, journal_task_type: nil)
        expect(task_template).to be_invalid
      end

      it 'is valid if associated to just a card' do
        task_template = FactoryGirl.build(:task_template, card: card, journal_task_type: nil)
        expect(task_template).to be_valid
      end

      it 'is valid if associated to just a journal task type' do
        task_template = FactoryGirl.build(:task_template, card: nil, journal_task_type: journal_task_type)
        expect(task_template).to be_valid
      end
    end
  end
end
