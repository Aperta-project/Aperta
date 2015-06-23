class RemoveTaskTypeIdFromJournalTaskTypes < ActiveRecord::Migration
  def change
    remove_column :journal_task_types, :task_type_id, :integer
  end
end
