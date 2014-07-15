class AddLockedByToPaper < ActiveRecord::Migration
  def change
    add_column :papers, :locked_by_id, :integer
  end
end
