class DisallowNullForTaskManagerInPhases < ActiveRecord::Migration
  def change
    change_column_null :phases, :task_manager_id, false
  end
end
