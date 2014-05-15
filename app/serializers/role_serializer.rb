class RoleSerializer < ActiveModel::Serializer
  attributes :id, :admin, :editor, :reviewer, :name
end
