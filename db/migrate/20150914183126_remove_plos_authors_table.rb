class RemovePlosAuthorsTable < ActiveRecord::Migration
  def up
    drop_table :plos_authors_plos_authors
    remove_column :authors, :actable_id
    remove_column :authors, :actable_type
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
