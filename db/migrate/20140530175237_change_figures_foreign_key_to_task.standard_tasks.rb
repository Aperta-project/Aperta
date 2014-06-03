# This migration comes from standard_tasks (originally 20140530174915)
class ChangeFiguresForeignKeyToTask < ActiveRecord::Migration
  def change
    rename_column :figures, :paper_id, :task_id
  end
end
