class AddRequiredPermissionAndAppliesToToJournalTaskType < ActiveRecord::Migration
  def change
    add_column :journal_task_types, :required_permission_action, :string
    add_column :journal_task_types, :required_permission_applies_to, :string
  end
end
