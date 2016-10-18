require 'rails_helper'

describe PlosBioTechCheck::InitialTechCheckTask do
  subject(:task) { FactoryGirl.create :initial_tech_check_task, paper: paper }
  let(:paper) do
    FactoryGirl.create(
      :paper,
      :submitted,
      :with_creator,
      journal: journal
    )
  end
  let(:journal){ FactoryGirl.create(:journal, :with_creator_role) }

  it_behaves_like 'a PlosBioTechCheck that notifies the author of changes'

  describe '.restore_defaults' do
    it_behaves_like '<Task class>.restore_defaults update title to the default'
    it_behaves_like '<Task class>.restore_defaults update old_role to the default'
  end

  describe '#round' do
    it 'initializes with the round 1' do
      expect(task.round).to eq 1
    end
  end

  describe '#increment_round' do
    context 'when the round key is correctly initialized in #body' do
      it 'increments the round by 1' do
        expect(task.body).to eq('round' => 1)
        task.increment_round!
        expect(task.round).to eq 2
      end
    end

    context 'when the round key is incorrectly initialized in #body' do
      it 'increments the round by 1' do
        task.update! body: {}
        task.increment_round!
        expect(task.round).to eq 2

        task.update! body: {hello: 'hi'}
        task.increment_round!
        expect(task.round).to eq 2
      end
    end
  end
end
