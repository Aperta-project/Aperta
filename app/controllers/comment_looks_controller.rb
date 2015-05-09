class CommentLooksController < ApplicationController
  respond_to :json

  def index
    respond_with current_user.comment_looks.includes(:comment, :phase).where(read_at: nil)
  end

  def destroy
    respond_with(current_user.comment_looks.destroy(params[:id]))
  end
end
