require 'rails_helper'

describe Paper::Updated::MarkTitleAndAbstractIncomplete do
  include EventStreamMatchers

  let!(:paper) { FactoryGirl.create(:paper, :with_tasks) }
  let!(:task) { FactoryGirl.create(:title_and_abstract_task, paper: paper) }
  let!(:other_task) { FactoryGirl.create(:authors_task, paper: paper) }

  context 'when there is a title and abstract task' do
    it 'marks the title and abstract task incomplete if there is one' do
      task.completed = true
      task.save

      expect do
        described_class.call('tahi:paper:updated', record: paper)
      end.to change { task.reload.completed }.to(false)
    end
  end

  context 'when there is no title and abstract task' do
    it 'does nothing' do
      expect do
        described_class.call('tahi:paper:updated', record: paper)
      end.to_not change { other_task.reload.completed }
    end
  end
end
