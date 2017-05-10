class JournalTaskTypeSerializer < ActiveModel::Serializer
  attributes :id, :title, :kind, :role_hint, :system_generated, :journal_id
end
