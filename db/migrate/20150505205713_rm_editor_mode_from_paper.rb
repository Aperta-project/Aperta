class RmEditorModeFromPaper < ActiveRecord::Migration
  def up
    remove_column :papers, :editor_mode
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
