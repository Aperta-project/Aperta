class MessageTaskSerializer < TaskSerializer
  embed :ids
  has_many :comments, include: true
  has_many :participants, serializer: UserSerializer, include: true, root: :users

  def participants
    object.participants.includes(:affiliations)
  end
end
