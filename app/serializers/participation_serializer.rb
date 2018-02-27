class ParticipationSerializer < AuthzSerializer
  attributes :id
  has_one :user, embed: :ids, include: true
  has_one :task, embed: :id, polymorphic: true

  private

  # TODO: APERTA-12693 Stop overriding this
  def can_view?
    true
  end
end
