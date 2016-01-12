class CurrentUserSerializer < ActiveModel::Serializer
  has_many :affiliations, include: true, embed: :ids
  has_one :permissions, include: true, embed: :ids
  attributes :id,
    :full_name,
    :first_name,
    :avatar_url,
    :username,
    :email,
    :site_admin

  def permissions
    PermissionsSerializer.new(
      'id' => 1,
      'table' => object.filter_authorized(:view_profile, object).as_json
    )
  end
end
