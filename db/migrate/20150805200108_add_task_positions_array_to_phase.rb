class AddTaskPositionsArrayToPhase < ActiveRecord::Migration
  def change
    add_column :phases, :task_positions, :integer, array: true, default: []
  end
end
