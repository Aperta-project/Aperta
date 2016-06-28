require 'rails_helper'

describe Paper::Updated::MarkTitleAndAbstractIncomplete do
  include EventStreamMatchers

  let!(:paper) { FactoryGirl.create(:paper, :with_tasks) }
  let!(:task) { FactoryGirl.create(:title_and_abstract_task, paper: paper) }
  let!(:other_task) { FactoryGirl.create(:authors_task, paper: paper) }

  context 'when the paper is processing again' do
    before do
      allow(paper).to receive(:previous_changes).and_return("processing" => ["true", "false"])
    end

    it 'marks the title and abstract task incomplete if there is one' do
      task.completed = true
      task.save

      expect do
        described_class.call('tahi:paper:updated', record: paper)
      end.to change { task.reload.completed }.to(false)
    end

    it 'does nothing to other tasks' do
      expect do
        described_class.call('tahi:paper:updated', record: paper)
      end.to_not change { other_task.reload.completed }
    end
  end

  context 'when something else has changed' do
    before do
      allow(paper).to receive(:previous_changes).and_return("body" => ["first", "second"])
    end

    it 'marks the title and abstract task incomplete if there is one' do
      task.completed = true
      task.save

      expect do
        described_class.call('tahi:paper:updated', record: paper)
      end.to_not change { task.reload.completed }
    end

    it 'does nothing to other tasks' do
      expect do
        described_class.call('tahi:paper:updated', record: paper)
      end.to_not change { other_task.reload.completed }
    end
  end
end
