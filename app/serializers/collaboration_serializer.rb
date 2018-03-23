class CollaborationSerializer < AuthzSerializer
  attributes :id
  has_one :user, embed: :id, include: true, serializer: FilteredUserSerializer
  has_one :paper, embed: :id

  def id
    object.id
  end

  def paper
    object.assigned_to
  end
end
