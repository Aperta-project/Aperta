class CommentSerializer < AuthzSerializer
  attributes :id, :body, :created_at, :entities

  has_one :task, embed: :id, polymorphic: true
  has_one :commenter, serializer: FilteredUserSerializer, include: true, root: :users, embed: :id
end
