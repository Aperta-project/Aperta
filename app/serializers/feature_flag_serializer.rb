class FeatureFlagSerializer < AuthzSerializer
  attributes :id, :name, :active

  private

  # TODO: APERTA-12693 Stop overriding this
  def can_view?
    true
  end
end
