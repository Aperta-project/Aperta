class ParticipationsController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy
  respond_to :json

  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  def create
    participation = task.participations.build(participation_params)
    if participation.save
      CommentLookManager.sync_task(task)
      if participation.participant_id != current_user.id
        UserMailer.delay.add_participant(current_user.id, participation.participant_id, task.id)
      end
    end
    respond_with participation
  end

  def show
    respond_with Participation.find(params[:id])
  end

  def destroy
    if participation.present?
      participation.destroy
      respond_with participation
    end
  end

  private

  def task
    @task ||=
      if params[:participation].present?
        Task.find(params[:participation][:task_id])
      else
        participation.task
      end
  end

  def participation
    @participation ||= Participation.find(params[:id])
  end

  def participation_params
    params.require(:participation).permit(:task_id, :participant_id)
  end

  def render_404
    head 404
  end

  def enforce_policy
    authorize_action!(task: task)
  end
end
