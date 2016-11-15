namespace :data do
  namespace :migrate do
    desc <<-DESC
      APERTA-7457: Removes JournalTaskTypes for TahiStandardTasks::PaperAdminTask.

      These are no longer nececessary now that Task is an abstract
      class. We want them removed so they do not show up in the UI
      of possible cards that a user can add to a paper.
    DESC
    task remove_paper_admin_task_journal_task_types: :environment do
      JournalTaskType.where(kind: 'TahiStandardTasks::PaperAdminTask').destroy_all
    end
  end
end
