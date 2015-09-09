Subscriptions.configure do
  add 'paper:resubmitted', Paper::Resubmitted::ReopenRevisionTasks
  add 'tahi_standard_tasks/register_decision_task:completed', RegisterDecisionTask::Completed::ReportingEventLogger
  add 'tahi_standard_tasks/paper_editor_task:completed', EditorAssigned::ReportingEventLogger
  add 'tahi_standard_tasks/paper_reviewer_task:completed', AllReviewersAssigned::ReportingEventLogger
end
