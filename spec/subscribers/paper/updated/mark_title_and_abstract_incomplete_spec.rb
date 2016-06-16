require 'rails_helper'

describe Paper::Updated::MarkTitleAndAbstractIncomplete do
  include EventStreamMatchers

  let!(:paper) { instance_double(Paper, id: 99) }
  let!(:task) { FactoryGirl.create(:title_and_abstract_task) }
  let!(:other_task) { FactoryGirl.create(:authors_task) }

  before do
    allow(paper).to receive(:processing).and_return(false)
  end

  context 'when there is a title and abstract task' do
    before do
      allow(paper).to receive(:tasks).and_return([task])
    end

    it 'marks the title and abstract task incomplete if there is one' do
      task.completed = true

      described_class.call('tahi:paper:updated', record: paper)

      expect(task.completed).to eq(false)
    end
  end

  context 'when there is no title and abstract task' do
    before do
      allow(paper).to receive(:tasks).and_return([other_task])
    end

    it 'does nothing' do
      described_class.call('tahi:paper:updated', record: paper)
    end
  end
end
