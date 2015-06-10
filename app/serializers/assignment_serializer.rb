class AssignmentSerializer < ActiveModel::Serializer
  attributes :id, :role, :created_at

  has_one :paper, embed: :id
  has_one :user, embed: :id, include: true
end
