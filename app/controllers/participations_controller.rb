class ParticipationsController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy
  respond_to :json

  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  def create
    if participation.save
      CommentLookManager.sync_task(task)
      if participation.participant_id != current_user.id
        UserMailer.delay.add_participant(current_user.id, participation.participant_id, task.id)
      end
    end
    respond_with participation
  end

  def show
    respond_with participation
  end

  def destroy
    participation.destroy
    respond_with participation
  end

  private

  def task
    @task ||= Task.find(participation_params[:task_id])
  end

  def participation
    @participation ||= begin
      if params[:id].present?
        Participation.find(params[:id])
      else
        task.participations.build(participation_params)
      end
    end
  end

  def participation_params
    params.require(:participation).permit(:task_id, :participant_id)
  end

  def render_404
    head 404
  end

  def enforce_policy
    authorize_action!(participation: participation)
  end
end
