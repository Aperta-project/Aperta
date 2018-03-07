# RoleSerializer is responsible for serializing a Role model as an API response.
class RoleSerializer < AuthzSerializer
  attributes :id, :name, :assigned_to_type_hint
  has_one :journal, embed: :id
end
