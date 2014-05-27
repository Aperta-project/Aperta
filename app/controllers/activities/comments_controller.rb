class Activities::CommentsController < ApplicationController
  respond_to :json
  def unread
    comment = Comment.find(params[:id])
    been_read = PublicActivity::Activity.where(trackable_id: comment.id,
                                                key: 'comment.read',
                                                owner_id: current_user.id).exists?
    respond_with been_read
  end
end
