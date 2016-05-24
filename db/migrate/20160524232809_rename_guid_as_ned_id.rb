class RenameGuidAsNedId < ActiveRecord::Migration
  def change
    rename_column :users, :em_guid, :ned_id
  end
end
