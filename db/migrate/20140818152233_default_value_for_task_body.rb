class DefaultValueForTaskBody < ActiveRecord::Migration
  def up
    execute "ALTER TABLE tasks ALTER COLUMN body SET DEFAULT '[]'::JSON"
    execute "UPDATE tasks SET body = '[]' WHERE body IS NULL"
    change_column :tasks, :body, :json, null: false
  end

  def down
    execute "ALTER TABLE tasks ALTER COLUMN body DROP DEFAULT"
    change_column :tasks, :body, :json, null: true
    execute "UPDATE tasks SET body = NULL WHERE body::text = '[]'::text"
  end
end
