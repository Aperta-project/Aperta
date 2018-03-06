class JournalTaskTypeSerializer < AuthzSerializer
  attributes :id, :title, :kind, :role_hint, :system_generated, :journal_id
end
