class TaskTemplatesController < ApplicationController
  before_action :authenticate_user!

  respond_to :json

  def show
    requires_user_can(:administer, journal)
    respond_with task_template
  end

  def create
    phase = PhaseTemplate.find(task_template_params[:phase_template_id])
    requires_user_can(:administer, phase.journal)
    task_template.save
    respond_with task_template
  end

  def update
    requires_user_can(:administer, journal)
    task_template.update_attributes(task_template_params)
    respond_with task_template
  end

  def destroy
    requires_user_can(:administer, journal)
    task_template.destroy
    respond_with task_template
  end

  private

  def task_template_params
    params.require(:task_template).permit(:title, :phase_template_id, :journal_task_type_id).tap do |whitelisted|
      whitelisted[:template] = params[:task_template][:template] || []
    end
  end

  def journal
    @journal ||= task_template.journal
  end

  def task_template
    @task_template ||= if params[:id]
      TaskTemplate.find(params[:id])
    else
      TaskTemplate.new(task_template_params)
    end
  end
end
