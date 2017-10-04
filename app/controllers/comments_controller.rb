class CommentsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  def index
    requires_user_can :view_discussion_footer, task
    respond_with task.comments, root: :comments
  end

  def create
    requires_user_can :edit_discussion_footer, task
    Activity.comment_created! comment, user: current_user
    respond_with comment if CommentLookManager.sync_comment(comment)
  end

  def show
    requires_user_can :view_discussion_footer, task
    respond_with comment
  end

  private

  def task
    @task ||= begin
      if params[:id].present?
        comment.task
      elsif params[:task_id]
        Task.find(params[:task_id])
      else
        Task.find(comment_params[:task_id])
      end
    end
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
end
