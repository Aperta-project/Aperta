class PaperTrackerSerializer < ActiveModel::Serializer
  attributes :id, :display_title, :paper_type, :roles, :submitted_at

  def display_title
    object.title.presence || object.short_title
  end

  def roles
    role_hash = object.paper_roles.group_by &:role
    role_hash.map do |name, roles|
      {
        name: name.capitalize,
        users: roles.map(&:user)
      }
    end
  end

  def comment_looks
    CommentLook.joins(:user, {
      comment: {task: { phase: :paper }}
    }).where("papers.id = #{object.id}").count
  end
end
