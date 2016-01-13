class AddRequiredPermissionIdToTask < ActiveRecord::Migration
  def change
    add_column :tasks, :required_permission_id, :integer
  end
end
