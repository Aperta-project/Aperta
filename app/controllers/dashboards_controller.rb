class DashboardsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @paper_tasks = current_user.tasks.group_by(&:paper)
    @papers = current_user.papers
    @all_submitted_papers = Paper.submitted if current_user.admin?
  end
end
