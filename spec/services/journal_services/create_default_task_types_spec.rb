require 'rails_helper'

describe JournalServices::CreateDefaultTaskTypes do
  include_context 'clean Task.all_task_types'

  let(:journal) { FactoryGirl.create(:journal) }

  it 'Creates missing task types for an existing journal' do
    journal.journal_task_types.first.destroy
    expect {
      JournalServices::CreateDefaultTaskTypes.call(journal)
    }.to change { journal.reload.journal_task_types.count }.by 1
  end

  it 'Updates title and old_role on an existing journal' do
    jtt = journal.journal_task_types.find_by(title: 'Ad-hoc')
    jtt.update(title: 'Old Title', old_role: 'author') # Simulate old values

    JournalServices::CreateDefaultTaskTypes.call(journal)

    expect(jtt.reload.title).to eq('Ad-hoc')
    expect(jtt.old_role).to eq('user')
  end
end
