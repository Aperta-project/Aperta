class CreateReviewerReportsForEachRound < DataMigration
  RAKE_TASK_UP = 'data:migrate:create_missing_reviewer_reports'.freeze
  RAKE_TASK_DOWN = 'data:migrate:remove_reviewer_reports_created_in_7993'.freeze
end
