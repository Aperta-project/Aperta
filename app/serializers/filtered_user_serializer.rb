class FilteredUserSerializer < AuthzSerializer
  attributes :id, :full_name, :username, :avatar_url

  private

  def can_view?
    # Any user can view "filtered users". See FilteredUsersController for more
    # information.
    true
  end
end
