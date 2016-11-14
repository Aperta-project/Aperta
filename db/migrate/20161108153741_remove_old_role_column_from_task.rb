class RemoveOldRoleColumnFromTask < ActiveRecord::Migration
  def change
    remove_column :tasks, :old_role, :string
  end
end
