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

  describe "authorize_update?" do
    let(:paper) { double('paper') }
    let(:user)  { build(:user, site_admin: admin) }
    let(:authorized) { task.authorize_update?(nil, user) }
    before do
      allow(task).to receive(:paper).and_return paper
      allow(paper).to receive(:in_revision?).and_return false
      allow(paper).to receive(:ongoing?).and_return ongoing
    end

    context "a non-metadata task with a submitted paper" do
      let(:task) { Task.new(type: 'Task') }
      let(:ongoing) { false }
      let(:admin) { false }

      it 'generally returns true' do
        expect(authorized).to eq(true)
      end
    end

    context "a metadata task" do
      class AMetadataTask < Task
        include MetadataTask
      end

      let(:task) { AMetadataTask.new(type: 'AMetadataTask') }

      context 'the paper has been submitted' do
        let(:ongoing) { false }

        context "the user is an admin" do
          let(:admin) { true }
          it 'always allows admins' do
            expect(authorized).to eq(true)
          end
        end

        context "the user is not an admin" do
          let(:admin) { false }
          it "doesn't allow a regular user" do
            expect(authorized).to eq(false)
          end
        end
      end

      context 'the paper has not been submitted' do
        let(:ongoing) { true }
        let(:admin) { false }
        it "allows a regular user" do
          expect(authorized).to eq(true)
        end
      end
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
