module DataTransformation
  # Correct existing permission states for APERTA-12318
  class FixPermissionStates < Base
    counter :broken_permissions, :unchanged_permissions

    ROLE_STATE_KEYS = {
      Role::CREATOR_ROLE => :creator,
      Role::REVIEWER_ROLE => :reviewer
    }.freeze

    def transform
      fix_permissions
      assert_fix_worked
    end

    def fix_permissions
      Role.find_each do |role|
        ideal_edit_state_names = role_states(role)
        permissions_to_check = existing_permissions(role)

        permissions_to_check.find_each do |p|
          ensure_ideal_states(role, p, ideal_edit_state_names)
        end
      end
    end

    # rubocop:disable Metrics/AbcSize,Rails/SkipsModelValidations
    def ensure_ideal_states(role, permission, ideal_state_names)
      state_names = permission.states.map(&:name).sort
      if state_names == ideal_state_names
        increment_counter :unchanged_permissions
      else
        increment_counter :broken_permissions

        new_permission = CardPermissions.get_task_permission(
          Card.find(permission.filter_by_card_id),
          permission.action,
          ideal_state_names
        )

        log "The #{permission.action} permission for #{role.name} on card #{permission.filter_by_card_id} changes from #{permission.id}:#{state_names} to #{new_permission.id}: #{ideal_state_names}"

        # Swap the old permission for the new one
        PermissionsRole.where(role_id: role.id, permission_id: permission.id).destroy_all

        # The new permission might already exist, as permissions have a many to many relationship with roles
        PermissionsRole.find_or_create_by(role_id: role.id, permission_id: new_permission.id)
      end
    end
    # rubocop:enable Metrics/AbcSize,Rails/SkipsModelValidations

    def assert_fix_worked
      log "Checking that it worked..."
      Role.find_each do |role|
        ideal_edit_state_names = role_states(role)
        permissions_to_check = existing_permissions(role)

        permissions_to_check.find_each do |p|
          state_names = p.states.map(&:name).sort
          assert(state_names == ideal_edit_state_names, "The #{p.action} permission (#{p.id}) for #{role.name} on card #{p.filter_by_card_id} should have states #{ideal_edit_state_names} but has #{state_names}")
        end
      end
      log "It worked!"
    end

    def role_states(r)
      state_key = ROLE_STATE_KEYS.fetch(r.name, :rest)
      CardPermissions::STATES.fetch(state_key).map(&:to_s).sort
    end

    # Find permissions for cards whose actions are 'stateful' per the
    # CardPermissions definition
    def existing_permissions(role)
      role.permissions.where.not(action: CardPermissions::STATELESS_ACTIONS).where.not(filter_by_card_id: nil)
    end
  end
end
