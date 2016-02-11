class CurrentUserSerializer < ActiveModel::Serializer
  include SideloadableSerializerHelper

  has_many :affiliations, include: true, embed: :ids
  attributes :id, :full_name, :first_name, :avatar_url, :username,
             :email, :site_admin

  side_load :permissions

  def permissions
    object.filter_authorized(:view_profile, object).serializable
  end
end
