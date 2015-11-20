class MoveDocxToVersionedText < ActiveRecord::Migration
  def up
    add_column :versioned_texts, :source, :string
    drop_table :manuscripts
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
