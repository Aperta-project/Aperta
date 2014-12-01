class RemoveMessageTasks < ActiveRecord::Migration
  def up
    execute <<-SQL
      UPDATE tasks SET type = 'Task' WHERE type = 'MessageTask';
      DELETE FROM journal_task_types WHERE kind = 'MessageTask';
    SQL
  end

  def down
  end
end
