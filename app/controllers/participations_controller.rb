class ParticipationsController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy, except: [:index]
  before_action :enforce_index_policy, only: [:index]

  respond_to :json

  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  def index
    respond_with task.participations, root: :participations
  end

  def create
    if participation.save
      CommentLookManager.sync_task(task)
      if participation.user_id != current_user.id
        participation.task.notify_new_participant(current_user, participation)
      end
      Activity.participation_created! participation, user: current_user
    end
    respond_with participation
  end

  def show
    respond_with participation
  end

  def destroy
    participation.destroy
    Activity.participation_destroyed! participation, user: current_user
    respond_with participation
  end

  private

  def task
    @task ||= begin
      if params[:id].present?
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
        task.participations.build(participation_params)
      end
    end
  end

  def participation_params
    params.require(:participation).permit(:task_id, :user_id)
  end

  def render_404
    head 404
  end

  def enforce_index_policy
    @task = Task.find(params[:task_id])
    if !current_user.can?(:view, @task)
      fail AuthorizationError
    end
  end

  def enforce_policy
    if !current_user.can?(:view, task)
      fail AuthorizationError
    end
  end
end
