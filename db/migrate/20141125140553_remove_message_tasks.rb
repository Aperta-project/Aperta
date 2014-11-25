class RemoveMessageTasks < ActiveRecord::Migration
  def up
    execute <<-SQL
      UPDATE tasks SET type = 'Task' where type = 'MessageTask';
      DELETE from journal_task_types where kind = 'MessageTask';
    SQL
  end

  def down
  end
end
