class LitePaperSerializer < ActiveModel::Serializer
  attributes :id, :title, :publishing_state, :old_roles,
             :related_at_date, :editable, :manuscript_id, :active,
             :created_at, :updated_at

  def related_at_date
    return unless scoped_user.present?
    my_roles.map(&:created_at).sort.last
  end

  def old_roles
    return unless scoped_user.present?
    object.role_descriptions_for(user: scoped_user)
  end

  private

  def my_roles
    @my_roles ||= object.roles_for(user: scoped_user)
  end

  def scoped_user
    scope.presence || options[:user]
  end
end
