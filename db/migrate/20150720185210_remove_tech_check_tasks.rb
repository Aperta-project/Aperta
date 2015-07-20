class RemoveTechCheckTasks < ActiveRecord::Migration
  def up
    execute <<-SQL
      DELETE FROM "tasks" WHERE "tasks"."type" = 'TahiStandardTasks::TechCheckTask';
    SQL
  end
end
