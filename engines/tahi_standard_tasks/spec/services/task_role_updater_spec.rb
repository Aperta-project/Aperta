require 'rails_helper'

describe TaskRoleUpdater do
  let(:paper) { FactoryGirl.create(:paper, :with_integration_journal) }
  let(:assignee) { FactoryGirl.create(:user) }
  let(:task) { FactoryGirl.create(:task, old_role: PaperRole::ADMIN, paper: paper) }

  subject do
    TaskRoleUpdater.new(task: task, assignee_id: assignee.id, paper_role_name: PaperRole::ADMIN)
  end

  it 'assigns the specified role to the user' do
    subject.update
    roles = paper.roles_for(
      user: assignee,
      roles: [paper.journal.staff_admin_role]
    )
    expect(roles).to be_present
  end

  it 'adds the specified user as a participant to the task' do
    subject.update
    expect(task.participants).to eq([assignee])
  end

  describe 'updating other tasks' do
    let!(:unrelated_role_task) do
      FactoryGirl.create(:task, paper: paper, old_role: 'foo')
    end
    let!(:related_completed_task) do
      FactoryGirl.create(
        :task,
        paper: paper,
        completed: true,
        old_role: task.old_role
      )
    end

    it 'does not update unrelated tasks' do
      subject.update
      expect(unrelated_role_task.participants).to be_empty
      expect(related_completed_task.participants).to be_empty
    end
  end
end
