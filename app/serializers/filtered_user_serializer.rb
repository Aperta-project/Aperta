class FilteredUserSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :username, :avatar_url
end
