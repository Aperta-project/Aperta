# We no longer have an editor at all, so we no longer need to store
# which editor to use.
class RemoveEditorModeFromPapers < ActiveRecord::Migration
  def up
    remove_column :papers, :editor_mode
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
