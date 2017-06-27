class RemoveJournalTaskTypesRequiredPermissions < ActiveRecord::Migration
  def change
    remove_column :journal_task_types, :required_permissions
    drop_table :permission_requirements
  end
end
