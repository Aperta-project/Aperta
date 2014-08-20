class CreateTaskTemplates < ActiveRecord::Migration
  def change
    create_table :task_templates do |t|
      t.string :title
      t.references :journal_task_type, index: true
      t.references :phase_template, index: true
      t.json :template
    end
  end
end
