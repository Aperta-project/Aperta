class PhaseSerializer < ActiveModel::Serializer
  attributes :id, :name, :position
  has_one :paper, embed: :ids
  has_many :tasks, embed: :ids, include: true, polymorphic: true

end
