class UserRoleSerializer < ActiveModel::Serializer
  attributes :id
  has_one :user, embed: :id
  has_one :old_role, embed: :id
end
