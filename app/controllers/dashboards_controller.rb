class DashboardsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @papers = current_user.papers
  end
end
