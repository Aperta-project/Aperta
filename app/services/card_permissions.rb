# Utility class to handle the permissions for a card and its instances.
class CardPermissions
  def self.add_roles(card, action, roles)
    task_permission = get_task_permission(card, action, ['*'])
    card_permission = get_card_permission(card)

    # When creating a new permission, append the roles if the permission already
    # existing and the client did not know about it.
    task_permission.roles.concat(*(roles - task_permission.roles))
    card_permission.roles.concat(*(roles - card_permission.roles))
    task_permission.save!
    card_permission.save!
    task_permission
  end

  def self.set_roles(card, action, roles)
    limited_roles = (
      roles & [card.journal.creator_role, card.journal.collaborator_role]
    )
    update_task_permission(card, action, Paper::EDITABLE_STATES, limited_roles)

    unlimited_roles = roles - limited_roles
    task_permission = update_task_permission(
      card, action, ['*'], unlimited_roles
    )

    card_permission = get_card_permission(card)
    card_permission.roles.replace(roles)
    card_permission.save!
    task_permission
  end

  def self.update_task_permission(card, action, states, roles)
    task_permission = get_task_permission(card, action, states)
    unless roles.empty?
      task_permission.roles.replace(roles)
      task_permission.save!
    end
    task_permission
  end

  def self.get_task_permission(card, action, states)
    Permission.ensure_exists(
      action,
      applies_to: 'Task',
      filter_by_card_id: card.id,
      states: states
    )
  end

  def self.get_card_permission(card)
    Permission.ensure_exists(
      'view',
      applies_to: 'CardVersion',
      filter_by_card_id: card.id
    )
  end
end
