class LitePaperSerializer < ActiveModel::Serializer
  attributes :id, :title, :paper_id, :short_title, :submitted, :roles, :unread_comments_count

  def paper_id
    id
  end

  def roles
    roles = []
    if defined?(current_user) && current_user
      # rocking this in memory because eager-loading
      roles = object.paper_roles.select { |role|
        role.user_id == current_user.id
      }.map(&:description)
      roles << "My Paper" if object.user_id == current_user.id
    end
    roles
  end

  def unread_comments_count
    if (defined? current_user) && current_user
      message_tasks = object.tasks.select { |t| t.is_a? MessageTask }
      message_tasks.reduce(0) do |sum, task|
        sum += CommentLook.where(user_id: current_user.id,
                                 comment_id: task.comments.pluck(:id),
                                 read_at: nil).count
      end
    end
  end
end
