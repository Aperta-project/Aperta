class CommentSerializer < ActiveModel::Serializer
  attributes :id, :body, :created_at, :entities

  has_one :task, embed: :id, polymorphic: true
  has_one :commenter, serializer: UserSerializer, include: true, root: :users, embed: :id

end
