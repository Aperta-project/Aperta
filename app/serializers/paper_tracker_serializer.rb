class PaperTrackerSerializer < ActiveModel::Serializer
  attributes :id, :display_title, :paper_type, :roles, :submitted_at

  def display_title
    object.title.presence || object.short_title
  end

  def roles
    object.journal.valid_roles.map do |role|
      {
        role_name: role,
        users: object.paper_roles.where(role: role).joins(:user).map(&:user)
      }
    end
  end
end
