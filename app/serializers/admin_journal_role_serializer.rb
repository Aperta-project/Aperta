# Provides a display-only representation of a role
class AdminJournalRoleSerializer < ActiveModel::Serializer
  attributes :id, :name, :journal_id, :assigned_to_type_hint

  has_many :card_permissions,
           embed: :ids,
           include: true,
           serializer: CardPermissionSerializer,
           root: :card_permissions

  def card_permissions
    custom_card_ids = Journal.find(journal_id).cards.map(&:id)
    Permission.where(
      filter_by_card_id: [custom_card_ids],
      applies_to: "Task"
    )
  end
end
