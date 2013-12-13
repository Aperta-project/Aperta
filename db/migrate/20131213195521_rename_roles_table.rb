class RenameRolesTable < ActiveRecord::Migration
  def change
    rename_table :roles, :journal_roles
  end
end
