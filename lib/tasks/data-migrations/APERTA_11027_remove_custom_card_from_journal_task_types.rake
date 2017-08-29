namespace :data do
  namespace :migrate do
    desc <<-DESC
      APERTA-11027: Remove "Custom Card" from the card picker in the admin workflow editor

      After the CustomCardTask model was added to the codebase, "rake data:update_journal_task_types"
      would ensure that a corresponding JournalTaskType row was added. Release 1.47 fixes the rake
      task so that it no longer attempts to add rows for CustomCardTask, however the old row still
      needs to be deleted so that "Custom Card" stops appearing in the picker.
    DESC

    task aperta_11027_remove_custom_card_from_journal_task_types: :environment do
      tasks = JournalTaskType.where(title: "Custom Card")
      if tasks.empty?
        raise Exception, "No matching journal task types were found."
      end
      JournalTaskType.transaction do
        tasks.each(&:delete)
        if JournalTaskType.where(title: "Custom Card").count > 0
          raise Exception "Failed to delete Custom Cards from JournalTaskTypes"
        end
      end
    end
  end
end
