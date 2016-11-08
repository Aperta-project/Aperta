require 'rails_helper'

describe JournalServices::UpdateDefaultTasks do
  it 'Updates task title to default' do
    cover_task = FactoryGirl.create(:cover_letter_task, title: 'Old Title')
    JournalServices::UpdateDefaultTasks.call
    expect(cover_task.reload.title).to eq('Cover Letter')
  end

  it 'Does not update Ad-hoc tasks title' do
    adhoc_task = FactoryGirl.create(:ad_hoc_task, title: 'Custom Ad-hoc Task')
    JournalServices::UpdateDefaultTasks.call
    expect(adhoc_task.reload.title).to eq('Custom Ad-hoc Task')
  end
end
