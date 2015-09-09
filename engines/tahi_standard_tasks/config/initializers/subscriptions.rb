Subscriptions.configure do
  add 'paper:resubmitted', Paper::Resubmitted::ReopenRevisionTasks
  add 'tahi_standard_tasks/register_decision_task:completed', RegisterDecisionTask::Completed::KeenLogger
end
