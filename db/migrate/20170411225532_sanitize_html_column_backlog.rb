class SanitizeHtmlColumnBacklog < DataMigration
  RAKE_TASK_UP =
    'data:migrate:html_sanitization:sanitize_snapshot_html'.freeze
end
