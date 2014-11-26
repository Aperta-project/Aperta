class UpdateTaskTypes < ActiveRecord::Migration
  def up
    execute <<-SQL
    UPDATE tasks SET type = 'SupportingInformation::SupportingInformationTask' WHERE type = 'SupportingInformation::Task';
    UPDATE journal_task_types SET kind = 'SupportingInformation::SupportingInformationTask' WHERE kind =  'SupportingInformation::Task';
    SQL
  end

  def down
    execute <<-SQL
    UPDATE tasks SET type = 'SupportingInformation::Task' WHERE type = 'SupportingInformation::SupportingInformationTask';
    UPDATE journal_task_types SET kind = 'SupportingInformation::Task' WHERE kind =  'SupportingInformation::SupportingInformationTask';
    SQL
  end
end
