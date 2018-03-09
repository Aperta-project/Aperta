# Provides a display-only representation of a role
class AdminJournalRoleSerializer < AuthzSerializer
  attributes :id, :name, :journal_id, :assigned_to_type_hint

  has_many :card_permissions,
           embed: :ids,
           include: true,
           serializer: CardPermissionSerializer,
           root: :card_permissions

  def card_permissions
    object.permissions.where.not(filter_by_card_id: nil).where(applies_to: 'Task')
  end

  private

  def can_view?
    scope.can?(:administer, Journal.find(journal_id))
  end
end
