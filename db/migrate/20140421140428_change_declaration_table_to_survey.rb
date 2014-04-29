class ChangeDeclarationTableToSurvey < ActiveRecord::Migration
  def change
    rename_table :declarations, :surveys
    remove_column :surveys, :paper_id, :integer
    add_column :surveys, :task_id, :integer
  end
end
