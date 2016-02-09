# Used to serialize PaperRole records.
class PaperRoleSerializer < ActiveModel::Serializer
  attributes :id, :old_role, :created_at

  has_one :paper, embed: :id
  has_one :user, embed: :id, include: true
end
