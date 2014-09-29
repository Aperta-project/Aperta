class AddTitleToTaskTemplates < ActiveRecord::Migration
  def change
    add_column :task_templates, :title, :string
  end
end
