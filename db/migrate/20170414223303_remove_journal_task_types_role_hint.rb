class RemoveJournalTaskTypesRoleHint < ActiveRecord::Migration
  def change
    remove_column :journal_task_types, :role_hint
  end
end
