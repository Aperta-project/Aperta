class CommentsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  def create
    task = Task.find(params[:comment][:message_task_id])
    p = PaperFilter.new task.paper, current_user
    if p.paper
      @comment = task.comments.create! new_comment_params
      render json: @comment
    else
      head 404
    end
  end

  def new_comment_params
    params.require(:comment).permit(:commenter_id, :body)
  end

  private

  def render_404
    head 404
  end
end
