class RenameOldRolesTablesAndFields < ActiveRecord::Migration
  def change
    rename_table :roles, :old_roles

    rename_column :flows, :role_id, :old_role_id
    rename_column :user_roles, :role_id, :old_role_id

    rename_column :journal_task_types, :role, :old_role
    rename_column :paper_roles, :role, :old_role
    rename_column :tasks, :role, :old_role
  end
end
