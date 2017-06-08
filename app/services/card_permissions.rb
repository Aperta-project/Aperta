# Utility class to handle the permissions for a card and its instances.
class CardPermissions
  # Give the roles permission action on a given card.
  # If the permission already has roles
  def self.add_roles(card, action, roles)
    grouped_roles = group_roles(card, roles)

    append_roles_and_save(get_card_permission(card), roles)

    [
      append_task_permission(
        card, action, Paper::EDITABLE_STATES, grouped_roles[:editable]
      ),
      append_task_permission(
        card, action, Paper::REVIEWABLE_STATES, grouped_roles[:reviewer]
      ),
      append_task_permission(
        card, action, [Permission::WILDCARD], grouped_roles[:rest]
      )
    ]
  end

  def self.set_roles(card, action, roles)
    grouped_roles = group_roles(card, roles)

    replace_roles_and_save(get_card_permission(card), roles)

    [
      replace_task_permission(
        card, action, Paper::EDITABLE_STATES, grouped_roles[:editable]
      ),
      replace_task_permission(
        card, action, Paper::REVIEWABLE_STATES, grouped_roles[:reviewer]
      ),
      replace_task_permission(
        card, action, [Permission::WILDCARD], grouped_roles[:rest]
      )
    ]
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
