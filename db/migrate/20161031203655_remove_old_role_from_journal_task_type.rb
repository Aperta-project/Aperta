class RemoveOldRoleFromJournalTaskType < ActiveRecord::Migration
  def change
    remove_column :journal_task_types, :old_role, :string
  end
end
