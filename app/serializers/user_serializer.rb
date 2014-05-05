class UserSerializer < ActiveModel::Serializer
  has_many :affiliations, include: true, embed: :ids
  attributes :id,
    :full_name,
    :image_url,
    :username,
    :email
end
