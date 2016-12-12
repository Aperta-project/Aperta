class LitePaperSerializer < ActiveModel::Serializer
  attributes :active, :created_at, :editable, :file_type, :id, :journal_id, :manuscript_id,
             :processing, :publishing_state, :related_at_date, :roles, :short_doi,
             :title, :updated_at

  def related_at_date
    return unless scoped_user.present?
    my_roles.map(&:created_at).sort.last
  end

  def roles
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
