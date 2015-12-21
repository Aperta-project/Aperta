require 'rails_helper'

describe JournalServices::CreateDefaultTaskTypes do
  let(:journal) { FactoryGirl.create(:journal) }

  it "creates missing task types for an existing journal" do
    jtt = journal.journal_task_types.first
    jtt.destroy!
    expect {
      JournalServices::CreateDefaultTaskTypes.call(journal)
    }.to change {
      journal.reload.journal_task_types.count
    }.by 1
  end

  it "doesn't change task types that exist on an existing journal" do
    jtt = journal.journal_task_types.first
    jtt.title = "dont change me"
    jtt.old_role = "dictator"
    jtt.save!
    expect {
      JournalServices::CreateDefaultTaskTypes.call(journal)
    }.to change {
      journal.reload.journal_task_types.count
    }.by 0

    expect(jtt.reload.title).to eq("dont change me")
    expect(jtt.old_role).to eq("dictator")
  end
end
