class RemoveTitleFromTaskTemplates < ActiveRecord::Migration
  def change
    remove_column :task_templates, :title, :string
  end
end
