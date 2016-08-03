require 'rails_helper'

describe TahiStandardTasks::InitialDecisionTask do
  let(:paper) { FactoryGirl.create :paper, :with_tasks }
  let(:task) { FactoryGirl.create :initial_decision_task }

  describe '.restore_defaults' do
    it_behaves_like '<Task class>.restore_defaults update title to the default'
    it_behaves_like '<Task class>.restore_defaults update old_role to the default'
  end

  describe '#initial_decision' do
    it 'gets initial decision' do
      expect(task.initial_decision).to eq(task.paper.decisions.last)
    end
  end

  describe '#paper_creation_hook' do
    it 'sets gradual_engagement attribute to true ' do
      expect(paper.gradual_engagement).to be_falsey
      task.paper_creation_hook(paper)
      expect(paper.reload.gradual_engagement).to be_truthy
    end
  end
end
