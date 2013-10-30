class DashboardsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @papers = Paper.all
  end
end
