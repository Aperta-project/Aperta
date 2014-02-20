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
    @flows = [["My Tasks", incomplete_tasks],
              ["My Papers", paper_admin_tasks],
              ["Done", complete_tasks]]
  end
end
