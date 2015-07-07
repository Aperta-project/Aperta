class PaperTrackerSerializer < ActiveModel::Serializer
  attributes :id, :display_title, :paper_type, :roles, :submitted_at, :comment_looks

  def display_title
    object.title.presence || object.short_title
  end

  def roles
    object.journal.valid_roles.map do |role|
      users = object.paper_roles.where(role: role).joins(:user).map(&:user)
      next if users.none?
      {
        name: role.capitalize,
        users: users
      }
    end.compact!
  end

  def comment_looks
    CommentLook.joins(:user, {
      comment: {task: { phase: :paper }}
    }).where("papers.id = #{object.id}").count
  end
end
