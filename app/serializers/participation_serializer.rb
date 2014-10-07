class ParticipationSerializer < ActiveModel::Serializer
  attributes :id
  has_one :participant, serializer: UserSerializer, embed: :ids, include: true, root: :users
  has_one :task, embed: :id, polymorphic: true
end
