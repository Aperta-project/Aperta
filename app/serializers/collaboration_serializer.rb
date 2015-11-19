class CollaborationSerializer < ActiveModel::Serializer
  attributes :id, :paper_id
  has_one :user, embed: :id, include: true
end
