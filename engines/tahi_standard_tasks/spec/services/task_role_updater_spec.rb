require 'rails_helper'

describe TaskRoleUpdater do
  let(:paper) { FactoryGirl.create(:paper) }
  let(:user) { FactoryGirl.create(:user) }
  let(:task) { FactoryGirl.create(:task, role: PaperRole::ADMIN, paper: paper) }


  it "assigns the specified role to the user" do
    TaskRoleUpdater.new(task, user.id, PaperRole::ADMIN).update
    expect(paper.role_for(user: user, role: PaperRole::ADMIN)).to exist
  end

  it "adds the specified user as a participant to the task" do
    TaskRoleUpdater.new(task, user.id, PaperRole::ADMIN).update
    expect(task.participants).to eq([user])
  end

  context "When the role is the reviewer" do
    let(:task) { FactoryGirl.create(:task, role: PaperRole::REVIEWER, paper: paper) }

    it "does not add the specified user as a participant to the task" do
      TaskRoleUpdater.new(task, user.id, PaperRole::REVIEWER).update
      expect(task.participants).to_not eq([user])
    end
  end

  describe "updating other tasks" do
    let!(:unrelated_role_task) { FactoryGirl.create(:task, paper: paper, role: "foo") }
    let!(:related_completed_task) { FactoryGirl.create(:task, paper: paper, completed: true, role: task.role) }

    it "does not update unrelated tasks" do
      TaskRoleUpdater.new(task, user.id, PaperRole::ADMIN).update
      expect(unrelated_role_task.participants).to be_empty
      expect(related_completed_task.participants).to be_empty
    end
  end
end
