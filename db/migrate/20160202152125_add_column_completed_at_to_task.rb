# Adding completed_at for paper tracker searches
class AddColumnCompletedAtToTask < ActiveRecord::Migration
  def up
    add_column :tasks, :completed_at, :datetime
    execute <<-SQL
      UPDATE tasks SET completed_at = '#{Time.zone.now}' WHERE completed = true
    SQL
  end

  def down
    remove_column :tasks, :completed_at
  end
end
