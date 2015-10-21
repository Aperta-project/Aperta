class RemoveLockFromPaper < ActiveRecord::Migration
  def change
    remove_column :papers, :locked_by_id, :integer
  end
end
