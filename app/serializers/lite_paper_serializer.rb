class LitePaperSerializer < ActiveModel::Serializer
  attributes :id, :title, :short_title, :publishing_state, :roles, :related_at_date, :editable, :active, :created_at, :updated_at

  def related_at_date
    return unless scoped_user.present?

    my_roles.map(&:created_at).sort.first
  end

  def roles
    return unless scoped_user.present?

    roles = my_roles.map(&:description)
    roles << "My Paper" if object.user_id == scoped_user.id
    roles
  end

  private

  def my_roles
    @my_roles_mem ||= object.paper_roles.select do |role|
      role.user_id == scoped_user.id
    end
  end

  def scoped_user
    scope.presence || options[:user]
  end
end
