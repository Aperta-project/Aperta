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
    if participation.save
      # create new R&P assignment
      Assignment.where(
        user: participation.user,
        role: task.journal.task_participant_role,
        assigned_to: participation.task
      ).first_or_create!

      CommentLookManager.sync_task(task)
      if participation.user_id != current_user.id
        participation.task.notify_new_participant(current_user, participation)
      end
      Activity.participation_created! participation, user: current_user
    end
    respond_with participation
  end

  def show
    requires_user_can(:view_participants, task)
    respond_with participation
  end

  def destroy
    requires_user_can(:manage_participant, task)
    # destroy new R&P assignment
    Assignment.where(
      user: participation.user,
      role: task.journal.task_participant_role,
      assigned_to: participation.task
    ).destroy_all

    participation.destroy
    Activity.participation_destroyed! participation, user: current_user
    respond_with participation
  end

  private

  def task
    @task ||= begin
      if params[:task_id]
        Task.find(params[:task_id])
      elsif params[:id].present?
        participation.task
      else
        Task.find(participation_params[:task_id])
      end
    end
  end

  def participation
    @participation ||= begin
      if params[:id].present?
        Participation.find(params[:id])
      else
        Participation.new(participation_params)
      end
    end
  end

  def participation_params
    params.require(:participation).permit(:task_id, :user_id)
  end

  def render_404
    head 404
  end
end
