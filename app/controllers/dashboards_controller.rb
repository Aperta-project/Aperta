class DashboardsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @all_submitted_papers = Paper.submitted if current_user.admin?
  end
end
