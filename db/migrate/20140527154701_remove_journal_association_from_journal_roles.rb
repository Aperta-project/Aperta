class RemoveJournalAssociationFromJournalRoles < ActiveRecord::Migration
  def change
    remove_column :journal_roles, :journal_id
    rename_table :journal_roles, :user_roles
    add_index :user_roles, [:user_id, :role_id]
  end
end
