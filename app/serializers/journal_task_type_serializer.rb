class JournalTaskTypeSerializer < ActiveModel::Serializer
  attributes :id, :title, :role, :journal_id
  has_one :task_type, embed: :id, include: true
end
