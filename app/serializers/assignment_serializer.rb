class AssignmentSerializer < ActiveModel::Serializer
  attributes :id, :role

  has_one :paper, embed: :id
  has_one :user, embed: :id
end
