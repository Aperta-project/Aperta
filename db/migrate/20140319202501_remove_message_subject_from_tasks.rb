class RemoveMessageSubjectFromTasks < ActiveRecord::Migration
  def change
    remove_column :tasks, :message_subject, :string
  end
end
