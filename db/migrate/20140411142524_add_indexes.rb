class AddIndexes < ActiveRecord::Migration
  def change
    add_index :tasks, [:id, :type]
    add_index :journal_roles, [:user_id, :journal_id]
    add_index :paper_roles, [:user_id, :paper_id]
    add_index :flows, :user_settings_id
    add_index :comments, [:commenter_id, :task_id]
  end
end
