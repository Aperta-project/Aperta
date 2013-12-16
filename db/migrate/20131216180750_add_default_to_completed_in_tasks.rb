class AddDefaultToCompletedInTasks < ActiveRecord::Migration
  def up
    change_column_default :tasks, :completed, false
    execute "UPDATE tasks SET completed = false WHERE completed IS NULL"
    change_column_null :tasks, :completed, false
  end

  def down
    change_column_null :tasks, :completed, true
    change_column_default :tasks, :completed, nil
  end
end
