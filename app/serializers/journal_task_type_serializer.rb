class JournalTaskTypeSerializer < ActiveModel::Serializer
  attributes :id, :title, :old_role, :kind, :system_generated, :journal_id
end
