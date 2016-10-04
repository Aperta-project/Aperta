# Part of migrating Task to AdHocTask
class ChangeBaseJournalTaskTypeKind < ActiveRecord::Migration
  def up
    execute "UPDATE journal_task_types SET kind='AdHocTask' WHERE kind='Task'"
  end

  def down
    execute "UPDATE journal_task_types SET kind='Task' WHERE kind='AdHocTask'"
  end
end
