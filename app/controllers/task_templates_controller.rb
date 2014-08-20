class TaskTemplatesController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy

  respond_to :json

  def show
    respond_with task_template
  end

  def create
    task_template.save
    respond_with task_template
  end

  def update
    task_template.update_attributes(task_template_params)
    respond_with task_template
  end

  def destroy
    task_template.destroy
    respond_with task_template
  end

  private

  def task_template_params
    params.require(:task_template).permit(:template, :phase_template_id, :journal_task_type_id)
  end

  def task_template
    @task_template ||= if params[:id]
      TaskTemplate.find(params[:id])
    else
      TaskTemplate.new(task_template_params)
    end
  end

  def enforce_policy
    authorize_action! task_template: task_template
  end
end
