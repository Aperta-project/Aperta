class FilteredUserSerializer < AuthzSerializer
  attributes :id, :full_name, :username, :avatar_url

  private

  # TODO: APERTA-12693 Stop overriding this
  def can_view?
    true
  end
end
