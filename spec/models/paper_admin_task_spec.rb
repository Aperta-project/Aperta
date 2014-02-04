require 'spec_helper'

describe PaperAdminTask do
  describe "defaults" do
    subject(:task) { PaperAdminTask.new }
    specify { expect(task.title).to eq 'Assign Admin' }
    specify { expect(task.role).to eq 'admin' }
  end

  describe "callbacks" do
    let(:phase) { Phase.create! task_manager: TaskManager.create! }
    let(:default_task_attrs) { { title: 'A title', role: 'admin', phase: phase } }

    describe "after_save" do
      let(:bob) { User.create! email: 'bob@plos.org',
          password: 'abcd1234',
          password_confirmation: 'abcd1234',
          username: 'bobplos' }

      let(:steve) { User.create! email: 'steve@plos.org',
        password: 'abcd1234',
        password_confirmation: 'abcd1234',
        username: 'steveplos' }

      context "when the assignee is not changing" do
        it "does not modify other tasks" do
          paper_admin_task = PaperAdminTask.create! assignee: bob, phase: phase
          task = Task.create! default_task_attrs
          paper_admin_task.update! completed: true
          expect(task.reload.assignee).to be_nil
        end
      end

      context "when there are admin tasks with no assignee" do
        let!(:task) { Task.create! default_task_attrs }

        it "assigns the task to the PaperAdminTask assignee" do
          PaperAdminTask.create! assignee: bob, phase: phase
          expect(task.reload.assignee).to eq(bob)
        end
      end

      context "when there are admin tasks with the old assignee" do
        let!(:paper_admin_task) { PaperAdminTask.create! assignee: bob, phase: phase }

        it "assigns the task to the PaperAdminTask assignee" do
          task = Task.create! default_task_attrs.merge(assignee: bob)
          paper_admin_task.update! assignee: steve
          expect(task.reload.assignee).to eq(steve)
        end

        context "when the new assignee is nil" do
          it "clears the assignee from the other admin tasks" do
            task = Task.create! default_task_attrs.merge(assignee: bob)
            paper_admin_task.update! assignee: nil
            expect(task.reload.assignee).to eq nil
          end
        end
      end

      context "when there are admin tasks assigned to another admin" do
        let(:dave) { User.create! email: 'dave@plos.org',
          password: 'abcd1234',
          password_confirmation: 'abcd1234',
          username: 'daveplos' }

        let!(:paper_admin_task) { PaperAdminTask.create! assignee: bob, phase: phase }

        it "does not assign the task to the PaperAdminTask assignee" do
          task = Task.create! default_task_attrs.merge(assignee: dave)
          paper_admin_task.update! assignee: steve
          expect(task.reload.assignee).to eq(dave)
        end
      end

      context "when there are completed tasks" do
        let!(:paper_admin_task) { PaperAdminTask.create! assignee: bob, phase: phase }

        it "does not assign the task to the PaperAdminTask assignee" do
          task = Task.create! default_task_attrs.merge(completed: true, assignee: bob)
          paper_admin_task.update! assignee: steve
          expect(task.reload.assignee).to eq bob
        end
      end

      describe "tasks in other phases in the same task manager" do
        let(:task_manager) { TaskManager.create! }
        let(:reading_phase) { Phase.create! task_manager: task_manager }
        let(:writing_phase) { Phase.create! task_manager: task_manager }
        let(:paper_admin_task) { PaperAdminTask.create! phase: reading_phase }

        it "updates their assignee" do
          task = Task.create! default_task_attrs.merge(phase: writing_phase)
          paper_admin_task.update! assignee: steve
          expect(task.reload.assignee).to eq steve
        end
      end

      describe "tasks in other task managers" do
        let(:reading_phase) { Phase.create! task_manager: TaskManager.create! }
        let(:writing_phase) { Phase.create! task_manager: TaskManager.create! }
        let(:paper_admin_task) { PaperAdminTask.create! phase: reading_phase }

        it "does not update their assignee" do
          task = Task.create! default_task_attrs.merge(phase: writing_phase)
          paper_admin_task.update! assignee: steve
          expect(task.reload.assignee).to be_nil
        end
      end
    end
  end

  describe "#assignees" do
    let(:task) { PaperAdminTask.new phase: paper.task_manager.phases.first }
    let(:paper) { Paper.create! short_title: 'hello',
                  journal: Journal.create!,
                  decision: "Accepted",
                  decision_letter: 'Lorem Ipsum' }

    it "returns admins for this paper's journal" do
      admins = double(:admins)
      expect(User).to receive(:admins).and_return admins
      expect(task.assignees).to eq admins
    end
  end
end
