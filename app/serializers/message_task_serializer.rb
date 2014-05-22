class MessageTaskSerializer < TaskSerializer
  embed :ids
  attributes :unread_comments_count
  has_many :comments, include: true
  has_many :participants, serializer: UserSerializer, include: true, root: :users

  def unread_comments_count
  end
end
