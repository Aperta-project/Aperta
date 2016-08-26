# Serializer used to send paper data through to the Paper Tracker
class PaperTrackerSerializer < LitePaperSerializer
  attributes :paper_type, :first_submitted_at, :submitted_at,
    :related_users, :cover_editors, :handling_editors

  def related_users
    object.participants_by_role.map do |(role_name, users)|
      {
        name: role_name,
        users: users
      }
    end
  end
end
