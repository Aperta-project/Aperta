# Provides a display-only representation of a role
class AdminJournalRoleSerializer < ActiveModel::Serializer
  attributes :id, :name, :journal_id, :assigned_to_type_hint
end
