class AddAssignedUserIdToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :assigned_user_id, :integer
  end
end
