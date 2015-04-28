class UserSerializer < ActiveModel::Serializer
  attributes :id,
    :full_name,
    :first_name,
    :avatar_url,
    :username,
    :email
end
