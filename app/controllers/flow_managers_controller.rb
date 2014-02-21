class FlowManagersController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_admin!

  def show
    incomplete_tasks = Task.assigned_to(current_user).incomplete.group_by { |t| t.paper }.to_a
    complete_tasks = Task.assigned_to(current_user).completed.map do |task|
      [task.paper, [task]]
    end
    paper_admin_tasks = PaperAdminTask.assigned_to(current_user).map do |task|
      [task.paper, []]
    end
    unassigned_papers = PaperAdminTask.where(assignee_id: nil).map do |task|
      [task.paper, [task]] if User.admins_for(task.paper.journal).include? current_user
    end.compact
    @flows = [["Up for grabs", unassigned_papers],
              ["My Tasks", incomplete_tasks],
              ["My Papers", paper_admin_tasks],
              ["Done", complete_tasks]]
  end
end
