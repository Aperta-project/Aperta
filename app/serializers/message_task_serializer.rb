class MessageTaskSerializer < TaskSerializer
  has_many :participants, serializer: UserSerializer, embed: :ids, include: true, root: :users

  def participants
    object.participants.includes(:affiliations)
  end
end
