class UpdateUploadManuscriptTaskType < ActiveRecord::Migration
  def up
    execute <<-SQL
    UPDATE tasks SET type = 'TahiUploadManuscript::UploadManuscriptTask' WHERE type = 'TahiUploadManuscript::Task';
    UPDATE journal_task_types SET kind = 'TahiUploadManuscript::UploadManuscriptTask' WHERE kind =  'TahiUploadManuscript::Task';
    SQL
  end

  def down
    execute <<-SQL
    UPDATE tasks SET type = 'TahiUploadManuscript::Task' WHERE type = 'TahiUploadManuscript::UploadManuscriptTask';
    UPDATE journal_task_types SET kind = 'TahiUploadManuscript::Task' WHERE kind =  'TahiUploadManuscript::UploadManuscriptTask';
    SQL
  end
end
