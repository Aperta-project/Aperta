class JournalTaskTypesController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy
  respond_to :json

  def update
    reset_empty_role
    journal_task_type.update!(journal_task_types_params)
    respond_with journal_task_type
  end

  private

  def reset_empty_role
    unless params[:journal_task_type][:old_role]
      params[:journal_task_type][:old_role] = TaskType.types[journal_task_type.kind][:default_role]
    end
  end

  def journal_task_types_params
    params.require(:journal_task_type).permit(:old_role, :title)
  end

  def journal_task_type
    @jtt ||= JournalTaskType.find(params[:id])
  end

  def enforce_policy
    authorize_action! journal_task_type: journal_task_type
  end
end
