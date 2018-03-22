class CollaborationSerializer < AuthzSerializer
  attributes :id
  has_one :user, embed: :id, include: true
  has_one :paper, embed: :id

  def id
    object.id
  end

  def paper
    object.assigned_to
  end

  private

  # TODO: APERTA-12693 Stop overriding this
  def can_view?
    true
  end
end
