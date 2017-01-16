class ReviewerReportTaskToReviewerReports < DataMigration
  RAKE_TASK_UP = 'data:migrate:nested_questions:reviewer_report_task_to_reviewer_report'.freeze
  RAKE_TASK_DOWN = 'data:migrate:nested_questions:reviewer_report_to_reviewer_report_task'.freeze
end
