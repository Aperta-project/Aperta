class MigrateFileTypeOnManuscriptAttachment < DataMigration
  RAKE_TASK_UP = 'data:migrate:migrate_file_type_on_manuscript_attachment'
  RAKE_TASK_DOWN = 'data:migrate:migrate_kind_back_to_nil'
end
