class DashboardsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @assigned_tasks = current_user.tasks
    @ongoing_papers = current_user.papers.ongoing
    @submitted_papers = current_user.papers.submitted
    @all_submitted_papers = Paper.submitted if current_user.admin?
  end
end
