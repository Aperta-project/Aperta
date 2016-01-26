class AddNotNullConstraintOnPapersTitle < ActiveRecord::Migration
  def up
    execute <<-SQL
      UPDATE papers SET title='Untitled' WHERE title IS NULL
    SQL

    change_column :papers, :title, :text, null: false
  end

  def down
    change_column :papers, :title, :text, null: true
  end
end
