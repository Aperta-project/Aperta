# Trigger paper tracker query data migration
class MovePaperTrackerQuerySubmittedToVersionDate < DataMigration
  RAKE_TASK_UP = 'paper_tracker_query:update_submitted_search'
end
