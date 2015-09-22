class CommentLooksController < ApplicationController
  respond_to :json

  def index
    respond_with current_user.comment_looks.includes(:comment)
  end

  def show
    respond_with current_user.comment_looks.find(params[:id])
  end

  def destroy
    respond_with(current_user.comment_looks.destroy(params[:id]))
  end
end
