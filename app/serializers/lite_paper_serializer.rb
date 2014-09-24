class LitePaperSerializer < ActiveModel::Serializer
  attributes :id, :title, :paper_id, :short_title, :submitted, :roles, :unread_comments_count, :related_at_date

  def paper_id
    id
  end

  def user
    if (defined? current_user) && current_user
      current_user
    else
      options[:user] # user has been explicitly passed into serializer
    end
  end

  def related_at_date
    if user.present?
      user.paper_roles.where(paper: object).order(created_at: :desc).pluck(:created_at).first
    end
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
      object.tasks.inject(0) do |sum, task|
        sum + CommentLook.where(user_id: current_user.id,
                                comment_id: task.comments.pluck(:id),
                                read_at: nil).count
      end
    end
  end
end
