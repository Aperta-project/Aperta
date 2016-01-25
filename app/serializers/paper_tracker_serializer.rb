class PaperTrackerSerializer < LitePaperSerializer
  attributes :paper_type, :submitted_at, :related_users

  def related_users
    role_hash = object.participants.group_by(&:role)
    role_hash.map do |role, participants|
      {
        name: role.name,
        users: participants.map(&:user)
      }
    end
  end
end
