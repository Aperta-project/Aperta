class CollaborationSerializer < ActiveModel::Serializer
  has_one :user, embed: :id, include: true
  has_one :paper, embed: :id
end
