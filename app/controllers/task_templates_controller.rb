class TaskTemplatesController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json

  def show
    respond_with TaskTemplate.find(params[:id])
  end

  def create
    task_template = TaskTemplate.create(task_template_params)
    respond_with task_template
  end

  def update
    task_template = TaskTemplate.find(params[:id])
    task_template.update_attributes(task_template_params)
    respond_with task_template
  end

  private

  def task_template_params
    params.require(:task_template).permit(:title, :template, :phase_template_id, :journal_task_type_id)
  end
end
