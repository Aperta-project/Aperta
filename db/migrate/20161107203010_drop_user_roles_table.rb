class DropUserRolesTable < ActiveRecord::Migration
  def change
    drop_table :user_roles
  end
end
