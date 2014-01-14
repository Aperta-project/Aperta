class DisallowNullForTitlePhaseAndRoleInTasks < ActiveRecord::Migration
  def change
    change_column_null :tasks, :phase_id, false
    change_column_null :tasks, :title, false
    change_column_null :tasks, :role, false
  end
end
