require 'rails_helper'

describe Task do
  let(:paper) { FactoryGirl.create :paper, :with_tasks }

  describe ".without" do
    let!(:tasks) do
      2.times.map do
        Task.create! title: "Paper Admin",
          completed: true,
          role: 'admin',
          phase_id: 3
      end
    end

    it "excludes task" do
      expect(Task.count).to eq(2)
      expect(Task.without(tasks.last).count).to eq(1)
    end
  end

  describe "#invitations" do
    let(:phase) { FactoryGirl.create :phase }
    let(:task) { FactoryGirl.create :invitable_task, phase: phase }
    let!(:invitation) { FactoryGirl.create :invitation, task: task }

    context "on #destroy" do
      it "destroy invitations" do
        expect {
          task.destroy!
        }.to change { Invitation.count }.by(-1)
      end
    end
  end
end
