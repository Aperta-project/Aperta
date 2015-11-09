namespace :data do
  namespace :migrate do
    namespace :tasks do
      desc 'Sets the Task roles to editor'
      task set_roles_to_editor: :environment do
        types = [
          'PlosBioTechCheck::FinalTechCheckTask',
          'PlosBioTechCheck::InitialTechCheckTask',
          'PlosBioTechCheck::RevisionTechCheckTask'
        ]
        Task.where(type: types).update_all(role: 'editor')
      end
    end
  end
end
