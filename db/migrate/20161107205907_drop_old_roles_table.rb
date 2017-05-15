class DropOldRolesTable < ActiveRecord::Migration
  def change
    drop_table :old_roles
  end
end
