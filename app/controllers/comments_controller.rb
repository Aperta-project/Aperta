class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy
  respond_to :json

  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  def create
    task = Task.find(params[:comment][:task_id])

    comment = task.comments.create(comment_params)
    respond_with comment
  end

  def show
    respond_with Comment.find(params[:id])
  end

  private

  def comment_params
    params.require(:comment).permit(:commenter_id, :body)
  end

  def render_404
    head 404
  end

  def enforce_policy
    authorize_action!(task: Task.find(params[:comment][:task_id]))
  end
end
