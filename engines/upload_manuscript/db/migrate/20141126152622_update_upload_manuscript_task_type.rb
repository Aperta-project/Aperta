class UpdateUploadManuscriptTaskType < ActiveRecord::Migration
  def up
    execute <<-SQL
    UPDATE tasks SET type = 'UploadManuscript::UploadManuscriptTask' WHERE type = 'UploadManuscript::Task';
    UPDATE journal_task_types SET kind = 'UploadManuscript::UploadManuscriptTask' WHERE kind =  'UploadManuscript::Task';
    SQL
  end

  def down
    execute <<-SQL
    UPDATE tasks SET type = 'UploadManuscript::Task' WHERE type = 'UploadManuscript::UploadManuscriptTask';
    UPDATE journal_task_types SET kind = 'UploadManuscript::Task' WHERE kind =  'UploadManuscript::UploadManuscriptTask';
    SQL
  end
end
