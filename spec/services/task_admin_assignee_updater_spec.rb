require 'spec_helper'

describe TaskAdminAssigneeUpdater do

    let(:task)  { PaperAdminTask.create!(phase: phase) }
    let(:paper) { FactoryGirl.create(:paper, :with_tasks) }
    let(:phase) { paper.phases.first }

    let(:jim) { FactoryGirl.create(:user) }
    let(:sally) { FactoryGirl.create(:user) }
    let(:bob) { FactoryGirl.create(:user) }
    let(:gus) { FactoryGirl.create(:user) }

    let(:updater) { TaskAdminAssigneeUpdater.new(task.reload) }


  describe "paper admin is being changed" do

    before(:each) { task.admin_id = sally.id }

    it "will set the paper admin" do
      updater.update
      expect(task.paper.reload.admin).to eq(sally)
    end


    describe "impact on other tasks" do

      let!(:incomplete_tasks) do
        2.times.map do
          Task.create!(phase: phase, assignee: nil, role: "admin", title: "Incomplete Task")
        end
      end

      let!(:complete_tasks) do
        2.times.map do
          Task.create!(phase: phase, assignee: bob, completed: true, role: "admin", title: "Complete Task")
        end
      end

      let!(:incomplete_tasks_with_assignee) do
        2.times.map do
          Task.create!(phase: phase, assignee: bob, completed: false, role: "admin", title: "Incomplete Task with Assignee")
        end
      end

      let(:other_paper) do
        FactoryGirl.create(:paper).tap do |p|
          phase = paper.phases.first
          PaperAdminTask.create(phase: phase)
        end
      end

      it "will change the assignee on other unassigned incomplete tasks" do
        updater.update
        expect(incomplete_tasks.map{ |t| t.reload.assignee}.uniq).to match_array([sally])
      end

      it "will not change the assignee on other completed tasks" do
        updater.update
        expect(task.paper.tasks.completed.map(&:assignee)).not_to include(sally)
      end

      it "will not change the assignee if one is already assigned" do
        updater.update
        expect(incomplete_tasks_with_assignee.map { |t| t.reload.assignee }.uniq).not_to include(sally)
      end

      it "will not change the assignee for tasks within another paper" do
        updater.update
        expect(other_paper.tasks.map(&:assignee)).not_to include(sally)
      end

      it "will not update the assignee for tasks that are assigned to a third party" do
        related_task = Task.create!(phase: phase, assignee: gus, completed: false, role: "admin", title: "Something")
        updater.update
        expect(related_task.reload.assignee).to eq(gus)
      end

      it "will update the assignee for tasks that are assigned to the previous admin" do
        paper.assign_admin!(bob)
        related_task = Task.create!(phase: phase, assignee: bob, completed: false, role: "admin", title: "Something")
        updater.update
        expect(related_task.reload.assignee).to eq(sally)
      end

    end

  end

end
