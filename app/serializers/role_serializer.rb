class RoleSerializer < ActiveModel::Serializer
  attributes :id,
             :name
  has_one :journal, embed: :id
end
