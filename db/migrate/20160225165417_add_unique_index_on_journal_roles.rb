class AddUniqueIndexOnJournalRoles < ActiveRecord::Migration
  def up
    remove_index :roles, [:journal_id]
    add_index :roles, [:journal_id, :name], unique: true
  end

  def down
    add_index :roles, [:journal_id]
    remove_index :roles, [:journal_id, :name]
  end
end
