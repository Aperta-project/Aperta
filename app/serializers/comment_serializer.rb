class CommentSerializer < ActiveModel::Serializer
  embed :ids
  attributes :id, :body, :created_at

  has_one :message_task
  has_one :commenter, serializer: UserSerializer, include: true, root: :users

  has_many :comment_looks, include: true, embed: :ids

  def comment_looks
    object.comment_looks.where(user: current_user, read_at: nil)
  end
end
