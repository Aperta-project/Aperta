class ChangeFiguresForeignKeyToTask < ActiveRecord::Migration
  def change
    rename_column :figures, :paper_id, :task_id
  end
end
