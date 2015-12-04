class LitePaperSerializer < ActiveModel::Serializer
  attributes :id, :title, :short_title, :publishing_state, :roles,
             :related_at_date, :editable, :manuscript_id, :active,
             :created_at, :updated_at

  def related_at_date
    return unless scoped_user.present?
    first_role = my_roles.order(created_at: :desc).first
    return unless first_role.present?
    first_role.created_at
  end

  def roles
    return unless scoped_user.present?

    roles = my_roles.map(&:description)
    roles << 'My Paper' if object.creator == scoped_user
    roles
  end

  private

  def my_roles
    object.paper_roles.where(user: scoped_user)
  end

  def scoped_user
    scope.presence || options[:user]
  end
end
