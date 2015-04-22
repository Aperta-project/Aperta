require 'rails_helper'

describe TaskRoleUpdater do
  let(:paper) { FactoryGirl.create(:paper) }
  let(:assignee) { FactoryGirl.create(:user) }
  let(:task) { FactoryGirl.create(:task, role: PaperRole::ADMIN, paper: paper) }

  subject do
    TaskRoleUpdater.new(task: task, assignee_id: assignee.id, paper_role_name: PaperRole::ADMIN)
  end

  it "assigns the specified role to the user" do
    subject.update
    expect(paper.role_for(user: assignee, role: PaperRole::ADMIN)).to exist
  end

  it "adds the specified user as a participant to the task" do
    subject.update
    expect(task.participants).to eq([assignee])
  end

  describe "updating other tasks" do
    let!(:unrelated_role_task) { FactoryGirl.create(:task, paper: paper, role: "foo") }
    let!(:related_completed_task) { FactoryGirl.create(:task, paper: paper, completed: true, role: task.role) }

    it "does not update unrelated tasks" do
      subject.update
      expect(unrelated_role_task.participants).to be_empty
      expect(related_completed_task.participants).to be_empty
    end
  end
end
