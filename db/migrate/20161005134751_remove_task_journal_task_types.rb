# This data migration is for removing JournalTaskType records
# that are tied to the Task class.
class RemoveTaskJournalTaskTypes < DataMigration
  RAKE_TASK_UP = 'data:migrate:remove_task_journal_task_types'
end
