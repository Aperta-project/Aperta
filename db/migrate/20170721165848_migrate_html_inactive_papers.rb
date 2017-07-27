class MigrateHtmlInactivePapers < DataMigration
  RAKE_TASK_UP = 'data:migrate:html_sanitization:html_sanitize_inactive_papers'.freeze
end
