class CommentSerializer < AuthzSerializer
  attributes :id, :body, :created_at, :entities

  has_one :task, embed: :id, polymorphic: true
  has_one :commenter, serializer: UserSerializer, include: true, root: :users, embed: :id

  private

  # TODO: APERTA-12693 Stop overriding this
  def can_view?
    true
  end
end
