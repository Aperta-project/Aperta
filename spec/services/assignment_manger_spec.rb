require 'spec_helper'

describe AssignmentManager do

  context "task has no assignee" do
    let(:task) { FactoryGirl.create(:task) }

    before { task.assignee = nil }

    it "returns nil if task has no assignee" do
      am = AssignmentManager.new(task, nil)
      expect(am.sync).to be_nil
    end
  end

  context "assignee has not changed" do
    let(:assignee) { FactoryGirl.create(:user) }
    let(:task) { FactoryGirl.create(:task, assignee: assignee).reload }
    let(:assignment_manager) { AssignmentManager.new(task, nil) }

    it "does not add participant" do
      expect {
        assignment_manager.sync
      }.to change { task.participants.count }.by(0)
    end

    it "does not send any emails" do
      expect {
        assignment_manager.sync
      }.to change(Sidekiq::Extensions::DelayedMailer.jobs, :size).by(0)
    end
  end

  context "assignee has changed" do
    context "new assignee is already a task participant" do
      let(:assignee) { FactoryGirl.create(:user) }
      let(:task) { FactoryGirl.create(:task, assignee: assignee, participants: [new_assignee]).reload }
      let(:assignment_manager) { AssignmentManager.new(task, new_assignee) }
      let(:new_assignee) { FactoryGirl.create(:user) }

      before do
        task.update(assignee: new_assignee)
      end

      it "does not add the new assignee again" do
        expect {
          assignment_manager.sync
        }.to change { task.participants.count }.by(0)
      end

      it "does not send out participant email" do
        expect {
          assignment_manager.sync
        }.to change(Sidekiq::Extensions::DelayedMailer.jobs, :size).by(0)
      end

      it "do not bother syncing comment looks" do
        expect(CommentLookManager).to_not receive(:sync_task)
        assignment_manager.sync
      end
    end

    context "new assignee is not a task participant" do
      let(:assignee) { FactoryGirl.create(:user) }
      let(:task) { FactoryGirl.create(:task, assignee: assignee).reload }
      let(:assignment_manager) { AssignmentManager.new(task, nil) }
      let(:new_assignee) { FactoryGirl.create(:user) }

      before do
        task.update(assignee: new_assignee)
      end

      it "adds the assignee as a participant" do
        expect {
          assignment_manager.sync
        }.to change { task.participants.count }.by(1)
      end

      it "sends out participant email" do
        expect {
          assignment_manager.sync
        }.to change(Sidekiq::Extensions::DelayedMailer.jobs, :size).by(2)
      end

      it "syncs comment looks" do
        expect(CommentLookManager).to receive(:sync_task).with(task)
        assignment_manager.sync
      end
    end

    describe "assignment email" do
      let(:assignee) { FactoryGirl.create(:user) }
      let(:task) { FactoryGirl.create(:task, assignee: assignee).reload }
      let(:new_assignee) { FactoryGirl.create(:user) }
      let(:assignment_manager) { AssignmentManager.new(task, new_assignee) }


      it "will send email when new assignee is not the assigner" do
        task.update(assignee: new_assignee)

        expect {
          assignment_manager.sync
        }.to change(Sidekiq::Extensions::DelayedMailer.jobs, :size).by(1)
      end

      it "will not send email when new assignee is the assigner" do
        task.update(assignee: assignee)

        expect {
          assignment_manager.sync
        }.to change(Sidekiq::Extensions::DelayedMailer.jobs, :size).by(0)
      end
    end
  end
end
