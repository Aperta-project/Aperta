class RoleSerializer < ActiveModel::Serializer
  attributes :id, :admin, :editor, :reviewer, :name
  has_one :journal, embed: :id
end
