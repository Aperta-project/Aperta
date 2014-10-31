class JournalTaskTypeSerializer < ActiveModel::Serializer
  attributes :id, :title, :role, :kind, :journal_id
end
