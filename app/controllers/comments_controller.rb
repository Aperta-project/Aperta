class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy
  respond_to :json

  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  def create
    comment = task.comments.build(comment_params)
    if comment.save
      CommentLookManager.sync_comment(comment)
    end
    respond_with comment
  end

  def show
    respond_with Comment.find(params[:id])
  end


  private

  def task
    @task ||= Task.find(params[:comment][:task_id])
  end

  def comment_params
    params.require(:comment).permit(:commenter_id, :body)
  end

  def render_404
    head 404
  end

  def enforce_policy
    authorize_action!(task: task)
  end
end
