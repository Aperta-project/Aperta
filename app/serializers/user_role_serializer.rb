class UserRoleSerializer < ActiveModel::Serializer
  attributes :id
  has_one :user, embed: :id
  has_one :role, embed: :id
end
