require 'spec_helper'

class TaskWithDefaults < Task
  title 'This task has a title'
  role 'This task has a role'
end

class TaskWithoutDefaults < Task
end

describe Task do
  describe "default_scope" do
    let(:paper) { Paper.create! short_title: 'Hello world', journal: Journal.create! }

    it "orders so the completed ones are below the incomplete ones" do
      completed_task = Task.create! title: "Paper Admin",
        completed: true,
        role: 'admin',
        phase: paper.task_manager.phases.first

      incomplete_task = Task.create! title: "Reviewer Report",
        completed: false,
        role: 'reviewer',
        phase: paper.task_manager.phases.first

      expect(Task.all.map(&:completed).last).to eq(true)

      task = Task.first
      task.update! completed: true
      expect(Task.first).to_not eq(task)
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
    specify { expect(Task.new.assignees).to eq [] }
  end
end
