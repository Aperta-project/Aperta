require 'rails_helper'

describe JournalServices::CreateDefaultTaskTypes do
  let(:journal) { FactoryGirl.create(:journal) }

  before do
    # Filter out anonymous classes.
    # This allows us to create test descendants of Task without polluting this.
    allow(Task).to receive(:all_task_types).and_wrap_original do |m|
      m.call.reject { |klass| klass.name.nil? }
    end
  end

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
