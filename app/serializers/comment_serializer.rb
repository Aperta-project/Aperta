class CommentSerializer < ActiveModel::Serializer
  attributes :id, :body, :created_at

  has_one :task, embed: :id, polymorphic: true
  has_one :commenter, serializer: UserSerializer, include: true, root: :users, embed: :id
  has_one :comment_look, include: true, embed: :id

  def comment_look
    CommentLookManager.comment_look(scope, object)
  end
end
