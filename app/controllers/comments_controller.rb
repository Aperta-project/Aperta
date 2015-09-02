class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy
  respond_to :json

  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  def create
    if !(journal_admin_is_current_user)
      ParticipationFactory.create(task: comment.task, assignee: current_user, assigner: current_user)
    end
    respond_with comment if CommentLookManager.sync_comment(comment)
  end

  def show
    respond_with comment
  end

  private

  def journal_admin_is_current_user
    current_user.administered_journals.include?(task.paper.journal)
  end

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
