# add unique index contraint to prevent duplicate state - permission
# relationships
class AddUniqueIndexToPermissionsStates < ActiveRecord::Migration
  def change
    add_index(
      :permission_states_permissions,
      [:permission_state_id, :permission_id],
      name: 'permission_states_ids_idx',
      unique: true
    )
  end
end
