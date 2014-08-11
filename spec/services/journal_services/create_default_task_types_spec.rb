require 'spec_helper'

describe JournalServices::CreateDefaultTaskTypes do
  let(:journal) { FactoryGirl.create(:journal) }

  it "creates new task types for a new journal" do
    expect(TaskType.count).to be > 0
    expect(journal.journal_task_types.count).to eq(TaskType.count)
  end

  it "creates missing task types for an existing journal" do
    jtt = journal.journal_task_types.first
    target_task_type = jtt.task_type
    jtt.destroy!
    expect {
      JournalServices::CreateDefaultTaskTypes.call(journal)
    }.to change {
      journal.reload.journal_task_types.count
    }.by 1

    expect(journal.journal_task_types.map(&:task_type)).to include(target_task_type)
  end

  it "doesn't change task types that exist on an existing journal" do
    jtt = journal.journal_task_types.first
    jtt.title = "dont change me"
    jtt.role = "dictator"
    jtt.save!
    expect {
      JournalServices::CreateDefaultTaskTypes.call(journal)
    }.to change {
      journal.reload.journal_task_types.count
    }.by 0

    expect(jtt.reload.title).to eq("dont change me")
    expect(jtt.role).to eq("dictator")
  end
end
