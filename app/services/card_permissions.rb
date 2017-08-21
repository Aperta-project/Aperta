# Utility class to handle the permissions for a card and its instances.
class CardPermissions
  # Map of state groups to the states they can edit in
  STATES = {
    creator: Paper::EDITABLE_STATES,
    reviewer: Paper::REVIEWABLE_STATES,
    rest: [Permission::WILDCARD]
  }.freeze

  # Append to the roles that can perform action on a card. Also, add the "view"
  # permission for the card (form) itself if the action is 'view'.
  def self.add_roles(card, action, roles)
    if action == 'view'
      append_roles_and_save(get_view_card_permission(card), roles)
      # Return an array, although there is only one permission to return, in
      # order to provide a consistent return value.
      [append_roles_and_save(
        get_task_permission(card, action, [Permission::WILDCARD]), roles
      )]
    else
      # Non-view roles are state-limited, that is, creators and collaborators
      # can only edit in the "editable" states, reviewers can only edit in the
      # "reviewable" states, etc. This means that these roles use a different
      # permission.
      grouped_roles = group_roles(card, roles)
      STATES.keys.map do |key|
        append_roles_and_save(
          get_task_permission(card, action, STATES[key]), grouped_roles[key]
        )
      end
    end
  end

  # Non-view roles are state-limited, that is, creators and collaborators
  # can only edit in the "editable" states, reviewers can only edit in the
  # "reviewable" states, etc. This means that these roles use a different
  # permission.
  def self.set_roles(card, action, roles, permission = nil)
    if action == 'view'
      replace_roles_and_save(get_view_card_permission(card), roles)
      # Return an array, although there is only one permission to return, in
      # order to provide a consistent return value.
      [replace_roles_and_save(
        get_task_permission(card, action, [Permission::WILDCARD]), roles
      )]
    else
      # Non-view roles are state-limited, that is, creators and collaborators
      # can only edit in the "editable" states, reviewers can only edit in the
      # "reviewable" states, etc. This means that these roles use a different
      # permission.
      grouped_roles = group_roles(card, roles)

      STATES.keys.map do |key|
        permission ||= get_task_permission(card, action, STATES[key])
        replace_roles_and_save(permission, grouped_roles[key])
      end
    end
  end

  # Return a task-level permission for an action on a given card in the given
  # states, or create one if none exists.
  def self.get_task_permission(card, action, states)
    Permission.ensure_exists(
      action,
      applies_to: 'Task',
      filter_by_card_id: card.id,
      states: states
    )
  end

  # Return the view card permission for a given card, or create one if none
  # exists.
  def self.get_view_card_permission(card)
    Permission.ensure_exists(
      'view',
      applies_to: 'CardVersion',
      filter_by_card_id: card.id
    )
  end

  def self.replace_roles_and_save(permission, roles)
    roles ||= []
    permission.roles.replace(roles)
    permission.save!
    permission
  end

  def self.append_roles_and_save(permission, roles)
    roles ||= []
    permission.roles.replace(roles | permission.roles)
    permission.save!
    permission
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
