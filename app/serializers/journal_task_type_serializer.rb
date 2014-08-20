class JournalTaskTypeSerializer < ActiveModel::Serializer
  attributes :id, :title, :role
  has_one :task_type, embed: :id, include: true
end
