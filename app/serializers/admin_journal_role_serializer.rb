# Provides a display-only representation of a role
class AdminJournalRoleSerializer < ActiveModel::Serializer
  attributes :id, :name, :journal_id, :assigned_to_type_hint

  has_many :card_permissions,
           include: true,
           embed: :ids,
           serializer: CardPermissionSerializer,
           root: :card_permissions

  def card_permissions
    custom_card_ids = Journal.find(journal_id).cards.map(&:id)
    z = Permission.where(
      filter_by_card_id: [custom_card_ids],
      applies_to: "Task"
    )
    y = object.permissions.where.not(filter_by_card_id: nil).where(applies_to: 'Task')
    # binding.pry
    return z

  end
end
