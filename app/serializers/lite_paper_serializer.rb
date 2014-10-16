class LitePaperSerializer < ActiveModel::Serializer
  attributes :id, :title, :short_title, :submitted, :roles, :unread_comments_count, :related_at_date

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
    if user.present?
      # rocking this in memory because eager-loading
      roles = object.paper_roles.select { |role|
        role.user_id == user.id
      }.map(&:description)
      roles << "My Paper" if object.user_id == user.id
    end
    roles
  end

  def unread_comments_count
    if user.present?
      CommentLook.joins(comment: [task: :paper])
        .where("papers.id" => object.id)
        .where('comment_looks.read_at is null')
        .where("comment_looks.user_id" => user.id).count
    end
  end
end
