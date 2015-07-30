module JournalServices

  class CreateDefaultRoles < BaseService
    def self.call(journal)
      with_noisy_errors do
        journal.roles.create!(name: 'Admin', kind: Role::ADMIN, can_administer_journal: true, can_view_all_manuscript_managers: true, can_view_flow_manager: true)
        journal.roles.create!(name: 'Editor', kind: Role::EDITOR)
        journal.roles.create!(name: 'Flow Manager', kind: Role::FLOW_MANAGER, can_view_flow_manager: true)
        journal.roles
      end
    end
  end
end
