class CleanupDeadTables < ActiveRecord::Migration
  def up
    drop_table :author_paper
    drop_table :rails_admin_histories
  end

  def down
    create_table :author_paper
    create_table :rails_admin_histories do |t|
      t.text :message
      t.string :username
      t.integer :item
      t.string :table
      t.integer :month, limit: 2
      t.integer :year, limit: 8
      t.timestamps
    end
    add_index :rails_admin_histories, ["item", "table", "month", "year"], name: "index_rails_admin_histories"
  end
end
