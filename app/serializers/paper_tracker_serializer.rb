class PaperTrackerSerializer < LitePaperSerializer
  attributes :paper_type, :submitted_at, :related_users

  def related_users
    role_hash = object.paper_roles.group_by &:role
    role_hash.map do |name, roles|
      {
        name: name.capitalize,
        users: roles.map(&:user)
      }
    end
  end
end
