class TaskTemplatesController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_user, except: :create

  respond_to :json

  def show
    respond_with task_template
  end

  def create
    phase = PhaseTemplate.find(task_template_params[:phase_template_id])
    requires_user_can(:administer, phase.journal)
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

  def update_setting
    task_template.setting(params[:name]).update!(value: params[:value])
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

  def verify_user
    requires_user_can(:administer, journal)
  end
end
