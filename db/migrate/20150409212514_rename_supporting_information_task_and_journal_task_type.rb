class RenameSupportingInformationTaskAndJournalTaskType < ActiveRecord::Migration
  def up
    execute "UPDATE tasks SET type='TahiStandardTasks::SupportingInformationTask' WHERE type='TahiSupportingInformation::SupportingInformationTask';"
    execute "UPDATE tasks SET type='TahiStandardTasks::SupportingInformationTask' WHERE type='TahiSupportingInformation::SupportingInformationTask';"
  end

  def down
    execute "UPDATE tasks SET type='TahiSupportingInformation::SupportingInformationTask' WHERE type='TahiStandardTasks::SupportingInformationTask';"
    execute "UPDATE journal_task_types SET kind='TahiSupportingInformation::SupportingInformationTask' WHERE kind='TahiStandardTasks::SupportingInformationTask';"
  end
end
