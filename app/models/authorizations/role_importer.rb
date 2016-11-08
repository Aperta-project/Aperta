module Authorizations
  # RoleImporter is used to efficiently import/recreate a role in the database.
  class RoleImporter
    attr_reader :role

    def initialize(role_definition)
      @role_definition = role_definition
      @permission_definitions = role_definition.permission_definitions
    end

    def import!
      find_or_create_role!
      delete_existing_permission_roles
      cache_data

      import_permission_states
      import_permissions
      import_permission_states_permissions
      import_permission_roles

      role
    end

    private

    def import_permission_states
      state_names = @permission_definitions.flat_map(&:states).uniq
      states_to_import = state_names - @pre_existing_states.map(&:name)
      @permission_states_to_import.concat(states_to_import)
      if @permission_states_to_import.any?
        PermissionState.import [:name], @permission_states_to_import.map { |c| [c] }
      end
    end

    def import_permissions
      @permissions_to_import = begin
        @permission_definitions.each_with_object([]) do |definition, arr|
          key = [ definition.action, definition.applies_to, definition.states ]

          # Re-use an existing permission if one exists for the same
          # action/applies_to/states
          existing_permission_id = @permission_id_by_key[key]
          if existing_permission_id
            @pre_existing_permissions.to_a.delete_if do |permission|
              permission.id == existing_permission_id
            end
            @permission_roles_to_import << [ existing_permission_id, @role.id ]
          else
            # we need to insert a new permission
            arr << [ definition.action, definition.applies_to ]
          end
        end.uniq
      end

      Permission.import [:action, :applies_to], @permissions_to_import
    end

    def import_permission_states_permissions
      permission_state_id_by_name = PermissionState.pluck(:id, :name).each_with_object({}) do |(id, name), hsh|
        hsh[name] = id
      end

      permission_id_by_action_and_applies_to = Permission.where.not(
        id: @pre_existing_permissions.map(&:id)
      ).pluck(:id, :action, :applies_to).each_with_object({}) do |(id, action, applies_to), hsh|
        hsh[[action, applies_to]] = id
      end

      @permission_states_permissions_to_import = []
      @permission_definitions.each do |definition|
        key = [ definition.action, definition.applies_to ]
        permission_id = permission_id_by_action_and_applies_to[key]

        definition.states.each do |state_name|
          # if the permission already existed we'll just re-use, so no
          # need to add it for import
          unless @pre_existing_permission_ids.include?(permission_id)
            @permission_states_permissions_to_import << [
              permission_id, permission_state_id_by_name[state_name]
            ]
          end
        end
      end

      PermissionStatesPermission.import [:permission_id, :permission_state_id], @permission_states_permissions_to_import
    end

    def import_permission_roles
      permissions_ids_for_this_role = Permission.where.not(
        id: @pre_existing_permission_ids
      ).pluck(:id)
      permissions_ids_for_this_role.each do |permission_id, arr|
        data = [permission_id, @role.id]
        @permission_roles_to_import << data
      end

      # This is final filtering. It's where permission_roles that already
      # exist in the database are filtered out so we don't duplicate two
      # of them, causing a UNIQUE CONSTRAINT violation.
      @permission_roles_to_import.delete_if do |data_to_import|
        @permissions_role_id_by_key.has_key?(data_to_import)
      end

      PermissionsRole.import [:permission_id, :role_id], @permission_roles_to_import.uniq
    end

    def cache_data
      @pre_existing_permissions = Permission.includes(:states)
      @pre_existing_permission_ids = @pre_existing_permissions.map(&:id)
      @pre_existing_states = PermissionState.all
      @pre_existing_permission_roles = PermissionsRole.all

      @permissions_to_import = []
      @permission_states_to_import = []
      @permission_roles_to_import = []

      cache_permission_id_by_key
      cache_permissions_role_id_by_key
    end

    def find_or_create_role!
      @role = Role.where(
        name: @role_definition.name,
        journal: @role_definition.journal
      ).first_or_create!

      @role_definition.participates_in.each do |klass|
        @role.update("participates_in_#{klass.to_s.downcase.pluralize}" => true)
      end
    end

    # Give our role no permissions. They will be re-wired up during the
    # import process.
    def delete_existing_permission_roles
      PermissionsRole.where(role_id: @role.id).delete_all
    end

    def cache_permission_id_by_key
      @permission_id_by_key = @pre_existing_permissions.each_with_object({}) do |permission, hsh|
        key = [
          permission.action,
          permission.applies_to,
          permission.states.map(&:name).map(&:to_s).sort
        ]
        hsh[key] = permission.id
      end
    end

    def cache_permissions_role_id_by_key
      @permissions_role_id_by_key = @pre_existing_permission_roles.each_with_object({}) do |permission_role, hsh|
        key = [
          permission_role.permission_id,
          permission_role.role_id
        ]
        hsh[key] = permission_role.id
      end
    end
  end
end
