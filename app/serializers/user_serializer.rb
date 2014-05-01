class UserSerializer < ActiveModel::Serializer
  attributes :id,
    :full_name,
    :image_url,
    :username,
    :affiliation,
    :email,
    :admin
end
