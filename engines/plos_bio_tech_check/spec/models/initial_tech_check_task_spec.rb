require 'rails_helper'

describe PlosBioTechCheck::InitialTechCheckTask do
  let(:author) { FactoryGirl.create :user }
  let(:paper) { FactoryGirl.create :paper_with_phases, :submitted, :with_tasks, creator: author }
  let(:phase) { FactoryGirl.create :phase, paper: paper }
  let(:task) { FactoryGirl.create :initial_tech_check_task, paper: paper, phase: phase }
  let(:subject) { described_class.new(paper: paper, phase: phase, title: "new task", old_role: PaperRole::COLLABORATOR) }
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

  describe "#changes_for_author_task" do
    it "returns the existing changes for author task" do
      existing_task = create :changes_for_author_task, paper: paper
      expect(subject.changes_for_author_task).to eq(existing_task)
    end

    it "creates a new changes_for_author_task card with author as a participant" do
      new_task = subject.changes_for_author_task

      expect(new_task.title).to eq("Changes For Author")
      expect(new_task.participants.length).to eq(1)
      expect(new_task.participants).to include(author)
    end
  end
end
