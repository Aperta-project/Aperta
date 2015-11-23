# There are some old JournalTaskTypes where the title still has "task"
# attached. This removes that.
class RenameExistingTechCheckJournalTaskTypes < ActiveRecord::Migration
  def up
    execute(%(UPDATE journal_task_types
              SET title='Final Tech Check'
              WHERE title='Final Tech Check Task'))

    execute(%(UPDATE journal_task_types
              SET title='Revision Tech Check'
              WHERE title='Revision Tech Check Task'))
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
