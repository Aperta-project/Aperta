# add unique index contraint to prevent duplicate state - permission
# relationships
class AddUniqueIndexToPermissionsStates < ActiveRecord::Migration
  def change
    add_index :permissions_states, [:state_id, :permission_id], unique: true
  end
end
