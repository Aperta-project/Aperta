class AddKindToJournalTaskType < ActiveRecord::Migration
  def up
    add_column :journal_task_types, :kind, :string
    execute "UPDATE journal_task_types jtt SET kind = tt.kind FROM task_types tt WHERE tt.id = jtt.task_type_id"
    drop_table :task_types
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
