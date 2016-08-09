# Provides a display-only representation of a role
class AdminJournalRoleSerializer < ActiveModel::Serializer
  attributes :id,
             :name,
             :journal_id
end
