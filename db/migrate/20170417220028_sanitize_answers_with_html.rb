class SanitizeAnswersWithHtml < DataMigration
  RAKE_TASK_UP =
    'data:migrate:html_sanitization:sanitize_answer_html'.freeze
end
