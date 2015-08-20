class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy
  respond_to :json

  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  def create
    ParticipationFactory.create(task: comment.task, assignee: current_user, assigner: current_user)
    comment.created_activity! current_user
    respond_with comment if CommentLookManager.sync_comment(comment)
  end

  def show
    respond_with comment
  end

  private

  def task
    @task ||= Task.find(comment_params[:task_id])
  end

  def comment
    @comment ||= begin
      if params[:id].present?
        Comment.find(params[:id])
      else
        task.comments.build(comment_params)
      end
    end
  end

  def comment_params
    params.require(:comment).permit(:commenter_id, :body, :task_id)
  end

  def render_404
    head 404
  end

  def enforce_policy
    authorize_action!(comment: comment)
  end
end
