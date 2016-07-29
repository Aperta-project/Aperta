class PopulateResourceTokensWithOldS3Links < DataMigration
  RAKE_TASK_UP = 'data:migrate:s3_attachments:populate_old_links'
end
