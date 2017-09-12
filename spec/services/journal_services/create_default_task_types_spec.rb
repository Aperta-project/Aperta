require 'rails_helper'

describe JournalServices::CreateDefaultTaskTypes do
  include_context 'clean Task.descendants'

  let(:journal) { FactoryGirl.create(:journal) }
  before do
    # Right now a journal instance will create a set of default journal task types and
    # seed a default ManuscriptManagerTempalte in an after_create hook.  This CardTaskType is referenced
    # indirectly in JournalServices::CreateDefaultManuscriptManagerTemplates and needs to exist before it runs
    CardTaskType.seed_defaults
  end

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
