# Enable role hints for display
class AddColumnRoleHintToJournalTaskType < ActiveRecord::Migration
  RAKE_TASK_UP = 'data:migrate:journal_task_types:set_role_hints'.freeze

  def change
    add_column :journal_task_types, :role_hint, :string
  end
end
