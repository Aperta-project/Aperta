class DefaultValueForTaskTemplatesTemplate < ActiveRecord::Migration
  def up
    execute "ALTER TABLE task_templates ALTER COLUMN template SET DEFAULT '[]'::JSON"
    execute "UPDATE task_templates SET template = '[]' WHERE template IS NULL"
    change_column :task_templates, :template, :json, null: false
  end

  def down
    execute "ALTER TABLE task_templates ALTER COLUMN template DROP DEFAULT"
    change_column :task_templates, :template, :json, null: true
    execute "UPDATE task_templates SET template = NULL WHERE template::text = '[]'::text"
  end
end
