class FilteredUsersSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :info, :avatar_url

  def info
    user = object.username
    user += ", #{role_names}" if options[:paper_id]
    user
  end

  private

  def role_names
    object.paper_roles.where(paper_id: options[:paper_id]).map(&:role).join(', ')
  end
end
