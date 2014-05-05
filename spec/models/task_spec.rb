require 'spec_helper'

class TaskWithDefaults < Task
  title 'This task has a title'
  role 'This task has a role'
end

class TaskWithoutDefaults < Task
end

describe Task do
  let(:paper) { FactoryGirl.create :paper, :with_tasks }

  describe "default_scope" do
    it "orders so the completed ones are below the incomplete ones" do
      completed_task = Task.create! title: "Paper Admin",
        completed: true,
        role: 'admin',
        phase: paper.phases.first

      incomplete_task = Task.create! title: "Reviewer Report",
        completed: false,
        role: 'reviewer',
        phase: paper.phases.first

      expect(Task.all.map(&:completed).last).to eq(true)

      task = Task.first
      task.update! completed: true
      expect(Task.first).to_not eq(task)
    end
  end

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
    let(:user)  { build(:user, admin: admin) }
    let(:authorized) { task.authorize_update?(nil, user) }
    before do
      allow(task).to receive(:paper).and_return paper
      allow(paper).to receive(:submitted?).and_return paper_submitted
    end

    context "a non-metadata task with a submitted paper" do
      let(:task) { Task.new(type: 'Task') }
      let(:paper_submitted) { true }
      let(:admin) { false }

      it 'generally returns true' do
        expect(authorized).to eq(true)
      end
    end

    context "a metadata task" do
      let(:task) { DeclarationTask.new(type: 'DeclarationTask') }

      context 'the paper has been submitted' do
        let(:paper_submitted) { true }

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
        let(:paper_submitted) { false }
        let(:admin) { false }
        it "allows a regular user" do
          expect(authorized).to eq(true)
        end
      end
    end
  end

  describe "initialization" do
    describe "title" do
      it "initializes title to specified title" do
        expect(TaskWithDefaults.new.title).to eq 'This task has a title'
      end

      context "when a title is provided" do
        it "uses the specified title" do
          expect(TaskWithDefaults.new(title: 'foo').title).to eq 'foo'
        end
      end
    end

    describe "role" do
      it "initializes role to specified role" do
        expect(TaskWithDefaults.new.role).to eq 'This task has a role'
      end

      context "when a role is provided" do
        it "uses the specified role" do
          expect(TaskWithDefaults.new(role: 'jester').role).to eq 'jester'
        end
      end
    end
  end

  describe "validations" do
    describe "title" do
      it "must be present" do
        expect(TaskWithDefaults.new.tap(&:valid?).errors_on :title).to be_empty
        expect(TaskWithoutDefaults.new.tap(&:valid?).errors_on :title).to include "can't be blank"
      end
    end

    describe "role" do
      it "must be present" do
        expect(TaskWithDefaults.new.tap(&:valid?).errors_on :role).to be_empty
        expect(TaskWithoutDefaults.new.tap(&:valid?).errors_on :role).to include "can't be blank"
      end
    end
  end

  describe "#assignees" do
    let(:task) { Task.create! title: "Paper Admin",
        role: 'admin',
        phase: paper.phases.first
    }

    let(:user) do
      User.create! username: 'albert',
        first_name: 'albert',
        last_name: 'einstein',
        email: 'einstein@example.org',
        password: 'password',
        password_confirmation: 'password'
    end

    let!(:journal_role) { JournalRole.create! user: user, journal: paper.journal, admin: true }

    it "returns all admins" do
      task.assignees
      expect(task.assignees).to include user
    end
  end
end
