class CommentLooksController < ApplicationController
  def update
    @comment_look = CommentLook.find(params[:id])
    if @comment_look.update(params.require(:comment_look).permit(:read_at))
      render json: @comment_look
    else
      head 404
    end
  end
end
