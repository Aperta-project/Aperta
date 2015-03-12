class UserSerializer < ActiveModel::Serializer
  has_many :affiliations, include: true, embed: :ids
  has_many :events, include: true, embed: :ids

  attributes :id,
    :full_name,
    :first_name,
    :avatar_url,
    :username,
    :email,
    :site_admin
end
