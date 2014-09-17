class CommentSerializer < ActiveModel::Serializer
  attributes :id, :body, :created_at

  has_one :task, embed: :id, polymorphic: true
  has_one :commenter, serializer: UserSerializer, include: true, root: :users, embed: :id
  has_many :comment_looks, include: true, embed: :ids

  def comment_looks
    CommentLookManager.comment_looks(object)
  end
end
