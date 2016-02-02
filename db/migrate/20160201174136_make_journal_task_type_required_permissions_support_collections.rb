class MakeJournalTaskTypeRequiredPermissionsSupportCollections < ActiveRecord::Migration
  def change
    remove_column :journal_task_types, :required_permission_action, :string
    remove_column :journal_task_types, :required_permission_applies_to, :string

    add_column :journal_task_types, :required_permissions, :json
  end
end
