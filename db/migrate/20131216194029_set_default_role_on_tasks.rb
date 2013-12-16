class SetDefaultRoleOnTasks < ActiveRecord::Migration
  def change
    execute "UPDATE tasks SET role = 'admin'"
  end
end
