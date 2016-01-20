# Add unique index contraint to prevent duplicate role - permission
# relationships
class AddUniqueIndexToPermissionsRoles < ActiveRecord::Migration
  def change
    add_index :permissions_roles, [:role_id, :permission_id], unique: true
  end
end
