class LitePaperSerializer < ActiveModel::Serializer
  attributes :id, :title, :short_title, :submitted, :roles, :related_at_date

  def related_at_date
    current_user.paper_roles.where(paper: object).order(created_at: :desc).pluck(:created_at).first
  end

  # TODO: should we modify this to show new task participants on their dashboard?
  # it only looks at paper_roles right now
  def roles
    # rocking this in memory because eager-loading
    roles = object.paper_roles.select { |role|
      role.user_id == current_user.id
    }.map(&:description)
    roles << "My Paper" if object.user_id == current_user.id
    roles
  end

  private

  def current_user
    scope.presence || options[:user]
  end
end
