class CurrentUserSerializer < ActiveModel::Serializer
  has_many :affiliations, include: true, embed: :ids
  attributes :id, :full_name, :first_name, :avatar_url, :username,
             :email, :site_admin

  def as_json(*args)
    hash = super(*args)
    hash[:permissions] = permissions.as_json
    hash
  end

  def permissions
    object.filter_authorized(:view_profile, object).serializable
  end
end
