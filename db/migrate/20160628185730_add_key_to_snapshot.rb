class AddKeyToSnapshot < ActiveRecord::Migration
  def change
    add_column :snapshots, :key, :string
    add_index :snapshots, :key
  end
end
