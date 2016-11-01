class JournalTaskTypeSerializer < ActiveModel::Serializer
  attributes :id, :title, :kind, :system_generated, :journal_id
end
