require 'spec_helper'

describe TaskAdminAssigneeUpdater do

    let(:task)  { PaperAdminTask.create(phase: phase, assignee: bob) }
    let(:paper) { Paper.create!(short_title: "something", journal: Journal.create!) }
    let(:phase) { paper.task_manager.phases.first }
    let(:sally) { User.create! email: 'sally@plos.org',
        password: 'abcd1234',
        password_confirmation: 'abcd1234',
        username: 'sallyplos' }
    let(:bob) { User.create! email: 'bob@plos.org',
        password: 'abcd1234',
        password_confirmation: 'abcd1234',
        username: 'bobplos' }

    let(:updater) { TaskAdminAssigneeUpdater.new(task.reload) }


  describe "paper admin is being changed" do

    before(:each) { task.admin_id = sally.id }

    it "will set the paper admin" do
      updater.update
      expect(task.paper.admin).to eq(sally)
    end


    describe "impact on other tasks" do

      let!(:incomplete_tasks) do
        3.times.map do
          Task.create(phase: phase, assignee: bob)
        end
      end

      let!(:complete_tasks) do
        3.times.map do
          Task.create(phase: phase, assignee: bob, completed: true)
        end
      end

      let(:other_paper) {
        Paper.create!(short_title: "something cooler", journal: Journal.create!).tap do |p|
          phase = paper.task_manager.phases.first
          PaperAdminTask.create(phase: phase, assignee: bob)
        end
      }

      it "will change the assignee on other uncompleted tasks" do
        updater.update
        expect(task.paper.tasks.incomplete.map(&:assignee).uniq).to match_array([sally])
      end

      it "will not change the assignee on other completed tasks" do
        updater.update
        expect(task.paper.tasks.completed.map(&:assignee)).not_to include(sally)
      end

      it "will not change the assignee for tasks within another paper" do
        updater.update
        expect(other_paper.tasks.map(&:assignee)).not_to include(sally)
      end
    end

    describe "impact on paper admin task" do

      it "will change the assignee if it was nil" do
        task.update_column(:assignee_id, nil)
        updater.update
        expect(task.reload.assignee).to eq(sally)
      end

      it "will change the assignee if same as previous admin" do
        # if paper.admin == new task.assginee, then update
      end

      it "will not change the assignee if same as previous admin"
    end

  end


      # admin jeff -> steve
      #
      # assignee jeff -> steve
      # assignee bob -> bob
      # assignee nil -> steve

  # describe "paper admin is being changed" do
  #   context "assignee being set is the same as previous admin" do
  #     it "will not change the assignee on the paper admin task"
  #   end
  #
  #   context "when the assignee is unrelated"
  #
  #   context "paper admin task without an admin assigned" do
  #     it "will change the assignee on the paper admin task"
  #   end
  # end

end
