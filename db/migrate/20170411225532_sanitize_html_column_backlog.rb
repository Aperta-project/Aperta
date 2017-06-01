class SanitizeHtmlColumnBacklog < DataMigration
  RAKE_TASK_UP =
    'data:migrate:html_sanitization:sanitize_database_html'.freeze
end
