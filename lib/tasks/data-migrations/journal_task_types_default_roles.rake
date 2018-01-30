namespace :data do
  namespace :migrate do
    namespace :journal_task_types do
      desc 'Sets the Journal Task Type roles to the editor'
      task set_roles_to_editor: :environment do
        types = [
          'FinalTechCheckTask',
          'InitialTechCheckTask',
          'RevisionTechCheckTask'
        ]
        JournalTaskType.where(kind: types).update_all(role: 'editor')
      end
    end
  end
end
