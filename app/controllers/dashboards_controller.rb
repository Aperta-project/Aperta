class DashboardsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @ongoing_papers = current_user.papers.ongoing
    @submitted_papers = current_user.papers.submitted
  end
end
