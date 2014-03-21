class CommentSerializer < ActiveModel::Serializer
  embed :ids
  attributes :id, :body, :created_at

  has_one :message_task
  has_one :commenter, serializer: UserSerializer, include: true, root: :users
end
