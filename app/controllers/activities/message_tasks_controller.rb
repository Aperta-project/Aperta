class Activities::MessageTasksController < ApplicationController
  respond_to :json
  def unread_comments_count
    task = Task.find(params[:id])
    comment_ids = task.comments.pluck(:id)
    read_count = PublicActivity::Activity.where(trackable_id: comment_ids,
                                                key: 'comment.read',
                                                owner_id: current_user.id).count
    total_count = comment_ids.count - read_count
    respond_with total_count
  end
end
