class SetDefaultTaskType < ActiveRecord::Migration
  def change
    change_column :tasks, :type, :string, default: 'Task'
  end
end
