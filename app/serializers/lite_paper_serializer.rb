class LitePaperSerializer < ActiveModel::Serializer
  attributes :id, :title, :short_title, :publishing_state, :roles, :related_at_date, :editable, :active

  def related_at_date
    return unless scoped_user.present?

    scoped_user.paper_roles.where(paper: object).order(created_at: :desc).pluck(:created_at).first
  end

  #TODO: this method does not include a tooltip if user is related to paper
  #      by just being a task participant (see pivotal #82588944)
  def roles
    return unless scoped_user.present?

    # rocking this in memory because eager-loading
    roles = object.paper_roles.select { |role|
      role.user_id == scoped_user.id
    }.map(&:description)
    roles << "My Paper" if object.user_id == scoped_user.id
    roles
  end

  private

  def scoped_user
    scope.presence || options[:user]
  end
end
