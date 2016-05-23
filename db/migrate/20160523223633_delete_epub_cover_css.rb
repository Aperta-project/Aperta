class DeleteEpubCoverCss < ActiveRecord::Migration
  def up
    remove_column :journals, :epub_cover
    remove_column :journals, :epub_css
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
