require 'rails_helper'

describe JournalServices::UpdateDefaultTasks do
  it 'Updates task attributes old_role and title to defaults' do
    cover_task = FactoryGirl.create(:cover_letter_task, title: 'Old Title',
                                                        old_role: 'editor')
    JournalServices::UpdateDefaultTasks.call
    expect(cover_task.reload.title).to eq('Cover Letter')
    expect(cover_task.old_role).to eq('author')
  end

  it 'Does not update Ad-hoc tasks title' do
    adhoc_task = FactoryGirl.create(:task, title: 'Custom Ad-hoc Task',
                                           old_role: 'user')
    JournalServices::UpdateDefaultTasks.call
    expect(adhoc_task.reload.title).to eq('Custom Ad-hoc Task')
    expect(adhoc_task.old_role).to eq('user')
  end
end
