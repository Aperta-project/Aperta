# Used to serialize Assignment records.
class AssignmentSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :assigned_to_id, :assigned_to_type

  has_one :user, embed: :id, include: true
  has_one :role, embed: :id, include: true
end
