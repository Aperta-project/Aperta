class AddTaskPaperJournalColumnsToEmailLog < ActiveRecord::Migration
  def change
    add_column :email_logs, :task_id, :integer
    add_column :email_logs, :paper_id, :integer
    add_column :email_logs, :journal_id, :integer
    add_column :email_logs, :additional_context, :jsonb

    add_index :email_logs, :task_id
    add_index :email_logs, :paper_id
    add_index :email_logs, :journal_id
  end
end
