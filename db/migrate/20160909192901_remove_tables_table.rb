# Remove the defunct tables table
class RemoveTablesTable < ActiveRecord::Migration
  def change
    drop_table :tables
  end
end
