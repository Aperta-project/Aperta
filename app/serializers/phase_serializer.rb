class PhaseSerializer < AuthzSerializer
  attributes :id, :name, :position
  has_one :paper, embed: :ids

  private

  # TODO: APERTA-12693 Stop overriding this
  def can_view?
    true
  end
end
