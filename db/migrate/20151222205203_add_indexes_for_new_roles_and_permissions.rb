class AddIndexesForNewRolesAndPermissions < ActiveRecord::Migration
  def change
    add_index 'assignments', ['role_id']
    add_index 'assignments', ['user_id']

    add_index 'permissions', ['action', 'applies_to']
    add_index 'permissions', ['applies_to']

    add_index 'permissions_roles', ['permission_id']
    add_index 'permissions_roles', ['role_id']

    add_index 'permissions_states', ['permission_id']

    add_index "roles", ["participates_in_papers"]
    add_index "roles", ["participates_in_tasks"]
  end
end
