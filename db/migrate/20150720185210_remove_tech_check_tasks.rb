class RemoveTechCheckTasks < ActiveRecord::Migration
  def up
    execute <<-SQL
      DELETE FROM "tasks" WHERE "tasks"."type" = 'TahiStandardTasks::TechCheckTask';
    SQL

    execute <<-SQL
      DELETE FROM "journal_task_types" WHERE "kind" = 'TahiStandardTasks::TechCheckTask';
    SQL
  end
end
