# Provides a display-only representation of a role
class AdminJournalRoleSerializer < ActiveModel::Serializer
  attributes :id, :name, :journal_id, :assigned_to_type_hint

  has_many :card_permissions,
           embed: :ids,
           include: true,
           serializer: CardPermissionSerializer,
           root: :card_permissions

  def card_permissions
    object.permissions.where.not(filter_by_card_id: nil)
  end
end
