class DashboardsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @ongoing_papers = current_user.papers.ongoing
    @submitted_papers = current_user.papers.submitted
    @all_submitted_papers = Paper.submitted if current_user.admin?
  end
end
