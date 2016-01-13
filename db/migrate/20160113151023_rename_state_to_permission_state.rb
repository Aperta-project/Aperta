# +State+ is too generic of a name so let's be more specific and rename it
# to +PermissionState+. 
class RenameStateToPermissionState < ActiveRecord::Migration
  def change
    rename_table :states, :permission_states
    rename_column :permissions_states, :state_id, :permission_state_id
    rename_table :permissions_states, :permission_states_permissions
  end
end
