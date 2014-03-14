class PhaseSerializer < ActiveModel::Serializer
  attributes :id, :name, :position
  has_one :paper
  has_many :tasks, embed: :ids, include: true, serializer: TaskSerializer
end
