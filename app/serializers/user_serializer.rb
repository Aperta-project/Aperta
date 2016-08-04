class UserSerializer < ActiveModel::Serializer
  attributes :id,
    :avatar_url,
    :first_name,
    :full_name,
    :last_name,
    :username
end
