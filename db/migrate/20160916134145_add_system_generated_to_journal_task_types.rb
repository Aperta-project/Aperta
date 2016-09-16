class AddSystemGeneratedToJournalTaskTypes < ActiveRecord::Migration
  def change
    add_column :journal_task_types, :system_generated, :boolean
  end
end
