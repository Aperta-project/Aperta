class ParticipationSerializer < ActiveModel::Serializer
  attributes :id
  has_one :user, embed: :ids, include: true
  has_one :task, embed: :id, polymorphic: true
end
