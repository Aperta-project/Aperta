class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_admin!

  def index
    @paper = Paper.find(params[:id])
    @task_manager = @paper.task_manager
  end
end
