class AddRoleToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :role, :string
  end
end
