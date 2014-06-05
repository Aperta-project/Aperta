class ChangeFigureForeignKeyToPaperId < ActiveRecord::Migration
  def change
    rename_column :figures, :task_id, :paper_id
  end
end
