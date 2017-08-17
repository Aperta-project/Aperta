class CurrentUserSerializer < ActiveModel::Serializer
  include SideloadableSerializerHelper

  has_many :affiliations, include: true, embed: :ids
  has_one  :orcid_account, include: true, embed: :id
  attributes :id,
    :full_name,
    :first_name,
    :avatar_url,
    :username,
    :email,
    :site_admin

  side_load :permissions

  def permissions
    object.filter_authorized(:*, object).serializable
  end

  def site_admin
    object.site_admin?
  end

  private

  def include_orcid_account?
    TahiEnv.orcid_connect_enabled?
  end
end
