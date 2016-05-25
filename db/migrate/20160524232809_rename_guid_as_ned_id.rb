class RenameGuidAsNedId < ActiveRecord::Migration
  def change
    remove_column :users, :em_guid, :string
    add_column :users, :ned_id, :integer
  end
end
