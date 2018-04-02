class PhaseSerializer < AuthzSerializer
  attributes :id, :name, :position
  has_one :paper, embed: :ids
end
