require 'rails_helper'

describe TaskRoleUpdater do
  let(:paper) { FactoryGirl.create(:paper) }
  let(:user) { FactoryGirl.create(:user) }
  let(:task) { FactoryGirl.create(:task, role: PaperRole::ADMIN, paper: paper)}


  it "assigns the specified role to the user" do
    TaskRoleUpdater.new(task, user.id, PaperRole::ADMIN).update
    expect(paper.role_for(user: user, role: PaperRole::ADMIN)).to exist
  end

  it "adds the specified user as a participant to the task" do
    TaskRoleUpdater.new(task, user.id, PaperRole::ADMIN).update
    expect(task.participants).to eq([user])
  end

  describe "updating other tasks" do
    let!(:unrelated_role_task) { FactoryGirl.create(:task, paper: paper, role: "foo")}
    let!(:related_completed_task) { FactoryGirl.create(:task, paper: paper, completed: true, role: task.role)}

    it "does not update unrelated tasks" do
      TaskRoleUpdater.new(task, user.id, PaperRole::ADMIN).update
      expect(unrelated_role_task.participants).to be_empty
      expect(related_completed_task.participants).to be_empty
    end
  end
end
