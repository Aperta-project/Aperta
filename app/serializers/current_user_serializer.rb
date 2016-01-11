class CurrentUserSerializer < ActiveModel::Serializer
  has_many :affiliations, include: true, embed: :ids
  has_many :permissions, include: true, embed: :ids
  attributes :id,
    :full_name,
    :first_name,
    :avatar_url,
    :username,
    :email,
    :site_admin

  def permissions
    [
      PermissionSerializer.new(
        id: 1,
        table: [{ object: { id: 3, type: 'User' },
                  permissions: { view_profile: { states: ['*'] } } }]
      )
    ]
  end
end
