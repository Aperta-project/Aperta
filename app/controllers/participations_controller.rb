class ParticipationsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  def index
    if current_user.can?(:view_participants, task)
      participations = task.participations
    else
      participations = []
    end
    respond_with participations, root: :participations
  end

  def create
    requires_user_can(:manage_participant, task)
    participant = User.find(participation_params[:user_id])
    participation = task.add_participant(participant)

    CommentLookManager.sync_task(task)
    if participation.user_id != current_user.id
      task.notify_new_participant(current_user, participation)
    end
    Activity.participation_created! participation, user: current_user

    respond_with participation, root: :participation
  end

  def show
    requires_user_can(:view_participants, task)
    respond_with participation, root: :participation
  end

  def destroy
    requires_user_can(:manage_participant, task)
    participation.destroy
    Activity.participation_destroyed! participation, user: current_user
    respond_with participation, root: :participation
  end

  private

  def task
    @task ||= begin
      if params[:task_id]
        Task.find(params[:task_id])
      elsif params[:id].present?
        participation.assigned_to
      else
        Task.find(participation_params[:task_id])
      end
    end
  end

  def participation
    @participation ||= Assignment.find(params[:id])
  end

  def participation_params
    params.require(:participation).permit(:task_id, :user_id)
  end

  def render_404
    head 404
  end
end
