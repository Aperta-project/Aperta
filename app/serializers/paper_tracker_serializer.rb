class PaperTrackerSerializer < LitePaperSerializer
  attributes :paper_type, :submitted_at, :related_users

  def related_users
    role_hash = object.paper_roles.group_by &:old_role
    role_hash.map do |name, old_roles|
      {
        name: name.capitalize,
        users: old_roles.map(&:user)
      }
    end
  end
end
