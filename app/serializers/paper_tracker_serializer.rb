class PaperTrackerSerializer < LitePaperSerializer
  attributes :paper_type, :submitted_at, :related_users

  def related_users
    role_hash = object.participations.group_by(&:role)
    role_hash.map do |role, participation|
      {
        name: role.name,
        users: participation.map(&:user)
      }
    end
  end
end
