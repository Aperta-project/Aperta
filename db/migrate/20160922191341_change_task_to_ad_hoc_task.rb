class ChangeTaskToAdHocTask < ActiveRecord::Migration
  def up
    execute "UPDATE tasks SET type='AdHocTask' WHERE type='Task'"
  end

  def down
    execute "UPDATE tasks SET type='Task' WHERE type='AdHocTask'"
  end
end
