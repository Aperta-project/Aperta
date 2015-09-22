class PhaseSerializer < ActiveModel::Serializer
  attributes :id, :name, :position
  has_one :paper, embed: :ids
end
