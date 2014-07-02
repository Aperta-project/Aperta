class UserSerializer < ActiveModel::Serializer
  has_many :affiliations, include: true, embed: :ids
  attributes :id,
    :full_name,
    :avatar_url,
    :username,
    :email,
    :admin
end
