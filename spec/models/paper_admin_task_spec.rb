require 'spec_helper'

describe PaperAdminTask do
  describe "callbacks" do
    let(:phase) { Phase.create!.tap { |p| TaskManager.create! phases: [p] } }

    describe "after_update" do
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
          task = Task.create! role: 'admin', phase: phase
          paper_admin_task.update! completed: true
          expect(task.reload.assignee).to be_nil
        end
      end

      context "when there are admin tasks with no assignee" do
        let!(:task) { Task.create! role: 'admin', phase: phase }

        it "assigns the task to the PaperAdminTask assignee" do
          PaperAdminTask.create! assignee: bob, phase: phase
          expect(task.reload.assignee).to eq(bob)
        end
      end

      context "when there are admin tasks with the old assignee" do
        let!(:paper_admin_task) { PaperAdminTask.create! assignee: bob, phase: phase }

        it "assigns the task to the PaperAdminTask assignee" do
          task = Task.create!(role: 'admin', assignee: bob, phase: phase)
          paper_admin_task.update! assignee: steve
          expect(task.reload.assignee).to eq(steve)
        end
      end

      context "when there are admin tasks assigned to another admin" do
        let(:dave) { User.create! email: 'dave@plos.org',
          password: 'abcd1234',
          password_confirmation: 'abcd1234',
          username: 'daveplos' }

        let!(:paper_admin_task) { PaperAdminTask.create! assignee: bob, phase: phase }

        it "does not assign the task to the PaperAdminTask assignee" do
          task = Task.create!(role: 'admin', assignee: dave, phase: phase)
          paper_admin_task.update! assignee: steve
          expect(task.reload.assignee).to eq(dave)
        end
      end

      context "when there are completed tasks" do
        let!(:paper_admin_task) { PaperAdminTask.create! assignee: bob, phase: phase }

        it "does not assign the task to the PaperAdminTask assignee" do
          task = Task.create! role: 'admin', completed: true, assignee: bob, phase: phase
          paper_admin_task.update! assignee: steve
          expect(task.reload.assignee).to eq bob
        end
      end

      describe "tasks in other phases in the same task manager" do
        let(:reading_phase) { Phase.create! }
        let(:writing_phase) { Phase.create! }
        let(:paper_admin_task) { PaperAdminTask.create! phase: reading_phase }

        before do
          TaskManager.create! phases: [reading_phase, writing_phase]
        end

        it "updates their assignee" do
          task = Task.create! role: 'admin', phase: writing_phase
          paper_admin_task.update! assignee: steve
          expect(task.reload.assignee).to eq steve
        end
      end

      describe "tasks in other task managers" do
        let(:reading_phase) { Phase.create! }
        let(:writing_phase) { Phase.create! }
        let(:paper_admin_task) { PaperAdminTask.create! phase: reading_phase }

        before do
          TaskManager.create! phases: [reading_phase]
          TaskManager.create! phases: [writing_phase]
        end

        it "does not update their assignee" do
          task = Task.create! role: 'admin', phase: writing_phase
          paper_admin_task.update! assignee: steve
          expect(task.reload.assignee).to be_nil
        end
      end
    end
  end

  describe "initialization" do
    describe "title" do
      it "initializes title to 'Paper Shepherd'" do
        expect(PaperAdminTask.new.title).to eq 'Paper Shepherd'
      end

      context "when a title is provided" do
        it "uses the specified title" do
          expect(PaperAdminTask.new(title: 'foo').title).to eq 'foo'
        end
      end
    end

    describe "role" do
      it "initializes title to 'admin'" do
        expect(PaperAdminTask.new.role).to eq 'admin'
      end

      context "when a role is provided" do
        it "uses the specified role" do
          expect(PaperAdminTask.new(role: 'foo').role).to eq 'foo'
        end
      end
    end
  end
end
