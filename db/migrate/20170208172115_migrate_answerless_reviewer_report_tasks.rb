class MigrateAnswerlessReviewerReportTasks < DataMigration
  RAKE_TASK_UP = 'data:migrate:nested_questions:answerless_reviewer_report_task_to_reviewer_report'.freeze
end
