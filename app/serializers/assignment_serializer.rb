# Used to serialize Assignment records.
class AssignmentSerializer < AuthzSerializer
  attributes :id, :created_at, :assigned_to_id, :assigned_to_type

  has_one :user, embed: :id, include: true, serializer: FilteredUserSerializer
  has_one :role, embed: :id, include: true

  private

  def can_view?
    return true if scope.nil?
    scope.can?(:assign_roles, object.assigned_to)
  end
end
