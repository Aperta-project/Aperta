module JournalServices

  class CreateDefaultRoles < BaseService
    def self.call(journal)
      with_noisy_errors do
        journal.old_roles.create!(name: 'Admin', kind: OldRole::ADMIN, can_administer_journal: true, can_view_all_manuscript_managers: true, can_view_flow_manager: true)
        journal.old_roles.create!(name: 'Editor', kind: OldRole::EDITOR)
        journal.old_roles.create!(name: 'Flow Manager', kind: OldRole::FLOW_MANAGER, can_view_flow_manager: true)
        journal.old_roles
      end
    end
  end
end
