class PermissionNotNulls < ActiveRecord::Migration
  def change
    change_column_null :permission_states, :name, false
    change_column_null :permission_states, :created_at, false
    change_column_null :permission_states, :updated_at, false

    change_column_null :permission_states_permissions, :permission_id, false
    change_column_null :permission_states_permissions, :permission_state_id, false
    change_column_null :permission_states_permissions, :created_at, false
    change_column_null :permission_states_permissions, :updated_at, false

    change_column_null :permissions, :action, false
    change_column_null :permissions, :applies_to, false
    change_column_null :permissions, :created_at, false
    change_column_null :permissions, :updated_at, false

    change_column_null :permissions_roles, :permission_id, false
    change_column_null :permissions_roles, :role_id, false
    change_column_null :permissions_roles, :created_at, false
    change_column_null :permissions_roles, :updated_at, false

    change_column_null :assignments, :user_id, false
    change_column_null :assignments, :role_id, false
    change_column_null :assignments, :assigned_to_id, false
    change_column_null :assignments, :assigned_to_type, false
    change_column_null :assignments, :created_at, false
    change_column_null :assignments, :updated_at, false

    change_column_null :roles, :name, false
    change_column_null :roles, :created_at, false
    change_column_null :roles, :updated_at, false
  end
end
