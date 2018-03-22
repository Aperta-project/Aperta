# Used to serialize Assignment records.
class AssignmentSerializer < AuthzSerializer
  attributes :id, :created_at, :assigned_to_id, :assigned_to_type

  has_one :user, embed: :id, include: true
  has_one :role, embed: :id, include: true

  private

  # TODO: APERTA-12693 Stop overriding this
  def can_view?
    true
  end
end
