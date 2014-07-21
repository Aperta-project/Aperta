class CollaborationSerializer < ActiveModel::Serializer
  attributes :id
  has_one :user, embed: :id, include: true
  has_one :paper, embed: :id

  def id
    object.id
  end
end
