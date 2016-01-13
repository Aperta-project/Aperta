class AddIndexOnRequiredPermissionIdOnTasks < ActiveRecord::Migration
  def change
    add_index :tasks, :required_permission_id
  end
end
