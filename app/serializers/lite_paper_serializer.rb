class LitePaperSerializer < ActiveModel::Serializer
  attributes :id, :title, :short_title, :submitted, :roles, :related_at_date

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
end
