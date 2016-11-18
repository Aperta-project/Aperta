require 'rails_helper'

describe JournalServices::CreateDefaultTaskTypes do
  include_context 'clean Task.descendants'

  let(:journal) { FactoryGirl.create(:journal) }

  it 'Creates missing task types for an existing journal' do
    journal.journal_task_types.first.destroy
    expect do
      JournalServices::CreateDefaultTaskTypes.call(journal)
    end.to change { journal.reload.journal_task_types.count }.by 1
  end

  it 'Updates title on an existing journal' do
    jtt = journal.journal_task_types.find_by(title: 'Ad-hoc for Staff Only')
    jtt.update(title: 'Old Title') # Simulate old values

    JournalServices::CreateDefaultTaskTypes.call(journal)

    expect(jtt.reload.title).to eq('Ad-hoc for Staff Only')
  end
end
