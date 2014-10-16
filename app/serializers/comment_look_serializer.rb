class CommentLookSerializer < ActiveModel::Serializer
  attributes :id, :read_at, :comment_id, :user_id, :task_id

  def task_id
    object.comment.task_id
  end
end
