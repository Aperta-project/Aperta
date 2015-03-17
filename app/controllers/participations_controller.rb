class ParticipationsController < ApplicationController
  include ActivityNotifier

  before_action :authenticate_user!
  before_action :enforce_policy

  respond_to :json

  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  def create
    if participation.save
      CommentLookManager.sync_task(task)
      if participation.user_id != current_user.id
        UserMailer.delay.add_participant(current_user.id, participation.user_id, task.id)
      end
      notify_participation!("created")
    end
    respond_with participation
  end

  def show
    respond_with participation
  end

  def destroy
    if participation.destroy
      notify_participation!("destroyed")
    end
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

  def notify_participation!(action)
    region_name = participation.task.submission_task? ? 'paper' : 'workflow'
    broadcast(event_name: "participation::#{action}", target: participation, scope: participation.task.paper, region_name: region_name)
  end

  def participation_params
    params.require(:participation).permit(:task_id, :user_id)
  end

  def render_404
    head 404
  end

  def enforce_policy
    authorize_action!(participation: participation)
  end
end
