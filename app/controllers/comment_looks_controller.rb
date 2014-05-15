class CommentLooksController < ApplicationController
  def update
    comment_look = CommentLook.find(params[:id])

    if comment_look.update comment_look_params
      render json: comment_look
    else
      head 404
    end
  end

  private

  def comment_look_params
    params.require(:comment_look).permit(:read_at)
  end
end
