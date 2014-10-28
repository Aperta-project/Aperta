class FilteredUsersSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :username, :avatar_url, :roles

  def info
    user = object.username
    user += role_names
    user
  end

  private

  def roles
    object.paper_roles.where(paper_id: options[:paper_id]).map(&:role)
  end
end
