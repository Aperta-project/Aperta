class JournalTaskTypeSerializer < ActiveModel::Serializer
  attributes :id, :title, :old_role, :kind, :journal_id
end
