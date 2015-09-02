class PhaseSerializer < ActiveModel::Serializer
  attributes :id, :name, :position, :links
  has_one :paper, embed: :ids


end
