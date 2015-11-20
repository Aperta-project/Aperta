class UploadManuscriptNamespaceCorrection < ActiveRecord::Migration
  def up
    execute <<-SQL
    UPDATE tasks SET type = 'TahiStandardTasks::UploadManuscriptTask' WHERE type = 'TahiUploadManuscript::UploadManuscriptTask';
    UPDATE journal_task_types SET kind = 'TahiStandardTasks::UploadManuscriptTask' WHERE kind = 'TahiUploadManuscript::UploadManuscriptTask';
    SQL
  end

  def down
    execute <<-SQL
    UPDATE tasks SET type = 'TahiUploadManuscript::UploadManuscriptTask' WHERE type = 'TahiStandardTasks::UploadManuscriptTask';
    UPDATE journal_task_types SET kind = 'TahiUploadManuscript::UploadManuscriptTask' WHERE kind = 'TahiStandardTasks::UploadManuscriptTask';
    SQL
  end
end
