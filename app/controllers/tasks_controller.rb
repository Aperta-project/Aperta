class TasksController < ApplicationController
  before_action :authenticate_user!

  def index
    @paper = Paper.find(params[:id])
    @task_manager = @paper.task_manager
  end
end
