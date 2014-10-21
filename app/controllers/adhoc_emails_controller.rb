class AdhocEmailsController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy

  def send_message
    AdhocMailer.delay.send_adhoc_email(params[:subject], params[:body], params[:recipients])
    head :ok
  end

  private

  def task
    Task.find(params[:task_id])
  end

  def enforce_policy
    authorize_action!(task: task)
  end
end
