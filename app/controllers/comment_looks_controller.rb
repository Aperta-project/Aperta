class CommentLooksController < ApplicationController
  respond_to :json

  def index
    respond_with current_user.comment_looks.includes(:comment, :phase).where(read_at: nil)
  end

  def update
    comment_look = CommentLook.find(params[:id])
    comment_look.update comment_look_params
    respond_with comment_look
  end

  private

  def comment_look_params
    params.require(:comment_look).permit(:read_at)
  end
end
