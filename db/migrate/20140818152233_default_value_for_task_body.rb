class DefaultValueForTaskBody < ActiveRecord::Migration
  def up
    execute "ALTER TABLE tasks ALTER COLUMN body SET DEFAULT '[]'::JSON"
    Task.where(body: nil).update_all(body: '[]')
    change_column :tasks, :body, :json, null: false
  end

  def down
    execute "ALTER TABLE tasks ALTER COLUMN body DROP DEFAULT"
    change_column :tasks, :body, :json, null: true
    Task.where("body::text = '[]'::text").update_all(body: nil)
  end
end
