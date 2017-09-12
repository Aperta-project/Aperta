require 'rails_helper'

describe JournalServices::CreateDefaultTaskTypes do
  include_context 'clean Task.descendants'

  let(:journal) { FactoryGirl.create(:journal) }

  it 'Creates missing task types for an existing journal' do
    JournalServices::CreateDefaultTaskTypes.call(journal)
    journal.journal_task_types.first.destroy
    expect do
      JournalServices::CreateDefaultTaskTypes.call(journal)
    end.to change { journal.reload.journal_task_types.count }.by 1
  end

  it 'Does not create task types Tasks where create_journal_task_type? is false' do
    journal.journal_task_types.destroy_all
    JournalServices::CreateDefaultTaskTypes.call(journal)
    expect(
      journal.reload.journal_task_types.where(kind: ['CustomCardTask',
                                                     'TahiStandardTasks::UploadManuscriptTask']).count
    ).to eq(0)
  end

  it 'Updates title on an existing journal' do
    jtt = FactoryGirl.create(:journal_task_type, journal: journal, kind: 'AdHocTask', title: 'Ad-hoc for Staff Only')
    jtt.update(title: 'Old Title') # Simulate old values

    JournalServices::CreateDefaultTaskTypes.call(journal)

    expect(jtt.reload.title).to eq('Ad-hoc for Staff Only')
  end
end
