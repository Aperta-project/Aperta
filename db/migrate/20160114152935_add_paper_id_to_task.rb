# Tasks have papers through phases currently in the app. This migration
# makes it so tasks have a direct relationship to paper. This simplifies
# queries for how tasks are looked up on papers (which is very often).
class AddPaperIdToTask < ActiveRecord::Migration
  def up
    add_column :tasks, :paper_id, :integer
    add_index :tasks, :paper_id

    execute <<-SQL
      UPDATE tasks
      SET paper_id=phases.paper_id
      FROM phases
      WHERE phase_id=phases.id
    SQL

    change_column :tasks, :paper_id, :integer, null: false
  end

  def down
    remove_column :tasks, :paper_id
  end
end
