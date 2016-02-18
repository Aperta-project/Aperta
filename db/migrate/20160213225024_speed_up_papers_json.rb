class SpeedUpPapersJson < ActiveRecord::Migration
  def change
    add_index :assignments, :assigned_to_type
    add_index :assignments, :assigned_to_id
    add_index :roles, :journal_id
  end
end
