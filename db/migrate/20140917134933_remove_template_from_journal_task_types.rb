class RemoveTemplateFromJournalTaskTypes < ActiveRecord::Migration
  def change
    remove_column :journal_task_types, :template, :json
  end
end
