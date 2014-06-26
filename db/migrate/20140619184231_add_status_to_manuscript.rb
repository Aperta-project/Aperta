class AddStatusToManuscript < ActiveRecord::Migration
  def up
    add_column :manuscripts, :status, :string, default: "processing"
    Manuscript.update_all status: "done"
  end

  def down
    remove_column :manuscripts, :status
  end
end
