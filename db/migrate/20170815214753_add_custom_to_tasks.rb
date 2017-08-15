class AddCustomToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :custom, :boolean, null: false, default: false
  end
end
