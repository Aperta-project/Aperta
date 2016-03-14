# RoleSerializer is responsible for serializing a Role model as an API response.
class RoleSerializer < ActiveModel::Serializer
  attributes :id,
             :name
  has_one :journal, embed: :id
end
