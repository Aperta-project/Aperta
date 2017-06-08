# Utility class to handle the permissions for a card and its instances.
class CardPermissions
  # Map of state groups to the states they can edit in
  STATES = {
    editable: Paper::EDITABLE_STATES,
    reviewer: Paper::REVIEWABLE_STATES,
    rest: [Permission::WILDCARD]
  }.freeze

  # Give the roles permission action on a given card.
  # If the permission already has roles
  def self.add_roles(card, action, roles)
    append_roles_and_save(get_card_permission(card), roles)

    grouped_roles = group_roles(card, roles)
    STATES.keys.map do |key|
      append_task_permission(card, action, STATES[key], grouped_roles[key])
    end
  end

  def self.set_roles(card, action, roles)
    replace_roles_and_save(get_card_permission(card), roles)

    grouped_roles = group_roles(card, roles)
    STATES.keys.map do |key|
      replace_task_permission(card, action, STATES[key], grouped_roles[key])
    end
  end

  def self.replace_task_permission(card, action, states, roles)
    get_task_permission(card, action, states).tap do |task_permission|
      replace_roles_and_save(task_permission, (roles || []))
    end
  end

  def self.get_task_permission(card, action, states)
    Permission.ensure_exists(
      action,
      applies_to: 'Task',
      filter_by_card_id: card.id,
      states: states
    )
  end

  def self.append_task_permission(card, action, states, roles)
    get_task_permission(card, action, states).tap do |task_permission|
      append_roles_and_save(task_permission, (roles || []))
    end
  end

  def self.replace_roles_and_save(permission, roles)
    permission.roles.replace(roles)
    permission.save!
  end

  def self.append_roles_and_save(permission, roles)
    permission.roles.concat(*(roles - permission.roles))
    permission.save!
  end

  def self.get_card_permission(card)
    Permission.ensure_exists(
      'view',
      applies_to: 'CardVersion',
      filter_by_card_id: card.id
    )
  end

  # Group roles into a hash with different keys:
  # =:creator= creator-style roles (collaborator or creator)
  # =:reviewer= reviewer roles
  # =;rest= The rest of the roles
  #
  # Used to determine which states their permissions should apply to
  def self.group_roles(card, roles)
    roles.group_by do |role|
      if [card.journal.creator_role,
          card.journal.collaborator_role].member?(role)
        :creator
      elsif role == card.journal.reviewer_role
        :reviewer
      else
        :rest
      end
    end
  end
end
