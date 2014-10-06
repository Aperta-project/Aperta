class ParticipationSerializer < ActiveModel::Serializer
  has_one :participant, serializer: UserSerializer, embed: :ids, include: true, root: :users
  has_one :task, embed: :id, polymorphic: true
end
