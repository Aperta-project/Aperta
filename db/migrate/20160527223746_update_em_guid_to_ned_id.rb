class UpdateEmGuidToNedId < ActiveRecord::Migration
  def change
    rename_column :billing_logs, :guid, :ned_id
    rename_column :billing_logs, :journal_id, :journal
  end
end
