class ParticipationSerializer < AuthzSerializer
  attributes :id
  has_one :user, embed: :ids, include: true
  has_one :task, embed: :id, polymorphic: true

  private

  def can_view?
    scope.can?(:view_participants, object.task)
  end
end
