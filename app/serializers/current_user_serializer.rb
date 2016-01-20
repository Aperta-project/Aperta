class CurrentUserSerializer < ActiveModel::Serializer
  has_many :affiliations, include: true, embed: :ids
  # has_many :permissions,
  #          include: true,
  #          embed_key: :id,
  #          serializer: PermissionResultSerializer
  attributes :id, :full_name, :first_name, :avatar_url, :username,
             :email, :site_admin

  # def permissions
  #   object.filter_authorized(:view_profile, object).serializable
  # end
end
