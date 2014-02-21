class FlowManagersController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_admin!

  def show
    respond_to do |format|
      format.json do
        bq = Task.joins(phase: {task_manager: :paper}).assigned_to(current_user)
        incomplete_tasks = bq.incomplete.group_by { |t| t.paper }.to_a
        complete_tasks = bq.completed.map do |task|
          [task.paper, [task]]
        end
        paper_admin_tasks = PaperAdminTask.joins(phase: {task_manager: :paper}).assigned_to(current_user).map do |task|
          [task.paper, []]
        end
        unassigned_papers = PaperAdminTask.joins(phase: {task_manager: :paper}).where(assignee_id: nil).map do |task|
          [task.paper, [task]] if User.admins_for(task.paper.journal).include? current_user
        end.compact
        @flows = [["Up for grabs", unassigned_papers],
                  ["My Tasks", incomplete_tasks],
                  ["My Papers", paper_admin_tasks],
                  ["Done", complete_tasks]]
      end
      format.html
    end
  end
end
