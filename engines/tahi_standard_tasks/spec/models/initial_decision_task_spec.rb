require 'rails_helper'

describe TahiStandardTasks::InitialDecisionTask do
  let(:paper) { FactoryGirl.create :paper, :submitted_lite, :with_tasks }
  let(:task) { FactoryGirl.create :initial_decision_task, paper: paper }

  describe '.restore_defaults' do
    include_examples '<Task class>.restore_defaults update title to the default'
    include_examples '<Task class>.restore_defaults update old_role to the default'
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

  describe 'after_register' do
    let(:decision) { paper.draft_decision }

    it "sets the decision to be initial" do
      task.after_register decision
      expect(decision.initial).to be(true)
    end

    it "sends an email to the author" do
      expect(TahiStandardTasks::InitialDecisionMailer)
        .to receive_message_chain(:delay, :notify)
        .with(decision_id: decision.id)
      task.after_register decision
    end
  end
end
