class ParticipationsController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy
  before_action :notify_participation_created, only: :create
  before_action :notify_participation_destroyed, only: :destroy

  respond_to :json

  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  def create
    if participation.save
      CommentLookManager.sync_task(task)
      if participation.user_id != current_user.id
        notify_participant_by_email
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
    params.require(:participation).permit(:task_id, :user_id)
  end

  def render_404
    head 404
  end

  def enforce_policy
    authorize_action!(participation: participation)
  end

  def notify_participant_by_email
    if params[:participation][:task_type] == 'EditorsDiscussionTask'
      UserMailer.delay.add_editor_to_editors_discussion participation.user_id, task.id
    else
      UserMailer.delay.add_participant current_user.id, participation.user_id, task.id
    end
  end

  def notify_participation_created
    if participation.valid?
      Activity.create(
        feed_name: 'manuscript',
        activity_key: 'participation.created',
        subject: participation.paper,
        user: current_user,
        message: "Added Contributor: #{participation.user.full_name}"
      )
    end
  end

  def notify_participation_destroyed
    Activity.create(
      feed_name: 'manuscript',
      activity_key: 'participation.destroyed',
      subject: participation.paper,
      user: current_user,
      message: "Removed Contributor: #{participation.user.full_name}"
    )
  end
end
