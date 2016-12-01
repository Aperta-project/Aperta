class MigrateFileTypeToKind < DataMigration
  RAKE_TASK_UP = 'data:migrate:migrate_file_type_to_kind'
  RAKE_TASK_DOWN = 'data:migrate:migrate_kind_back_to_nil'
end
