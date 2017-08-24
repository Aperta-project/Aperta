# Utility class to handle the permissions for a card and its instances.
class CardPermissions
  # Map of state groups to the states they can edit in
  STATES = {
    creator: Paper::EDITABLE_STATES,
    reviewer: Paper::REVIEWABLE_STATES,
    rest: [Permission::WILDCARD]
  }.freeze

  STATELESS_ACTIONS = ['view', 'view_discussion_footer'].freeze

  # Append to the roles that can perform action on a card. Also, add the "view"
  # permission for the card (form) itself if the action is 'view'.
  def self.add_roles(card, action, roles, permission = nil)
    # Append to the roles that can perform action on a card. Also, add the "view"
    # permission for the card (form) itself if the action is 'view'.
    set_or_add_roles(card, action, roles, permission, 'append')
  end

  def self.set_roles(card, action, roles, permission = nil)
    # wipeout and replace the roles that can perform action on a card
    set_or_add_roles(card, action, roles, permission, 'replace')
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
  def self.get_view_card_permission(card, action)
    Permission.ensure_exists(
      action,
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

  private

  def self.set_or_add_roles(card, action, roles, permission = nil, actor_string)
    # actor string determines to call replace_roles_and_save or append_roles_and_save above
    if STATELESS_ACTIONS.include?(action)
      update_stateless_permissions(card, action, roles, actor_string)
    else
      update_stateful_permissions(card, action, roles, permission, actor_string)
    end
  end

  def self.update_stateful_permissions(card, action, roles, permission = nil, actor_string)
    actor = compose_actor(actor_string)
    # if a permission is explictly passed, no need to look through states to find
    # correct permission. just update that one and return
    return send(actor, permission, roles) if permission

    grouped_roles = group_roles(card, roles)

    STATES.keys.map do |key|
      permission = get_task_permission(card, action, STATES[key])
      send(actor, permission, grouped_roles[key])
    end
  end

  def self.update_stateless_permissions(card, action, roles, actor_string)
    actor = compose_actor(actor_string)
    # Non-view roles are state-limited, that is, creators and collaborators
    # can only edit in the "editable" states, reviewers can only edit in the
    # "reviewable" states, etc. This means that these roles use a different
    # permission.
    view_permission = get_view_card_permission(card, action)
    send(actor, view_permission, roles)

    # Return an array, although there is only one permission to return, in
    # order to provide a consistent return value.
    task_permission = get_task_permission(card, action, [Permission::WILDCARD])
    [send(actor, task_permission, roles)]
  end

  def self.compose_actor(actor_string)
    (actor_string + '_roles_and_save').to_sym
  end
end
