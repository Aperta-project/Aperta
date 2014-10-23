class FilteredUsersSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :info, :avatar_url

  def info
    user = object.username
    user += role_names
    user
  end

  private

  def role_names
    roles = object.paper_roles.where(paper_id: options[:paper_id])
    roles.present? ? ", #{roles.map(&:role).join(', ')}" : ""
  end
end
