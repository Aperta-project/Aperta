class AddAssignedUserIdToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :assigned_user_id, :integer
    add_index :tasks, :assigned_user_id
  end
end
