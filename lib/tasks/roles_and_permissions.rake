namespace :'roles-and-permissions' do
  desc 'Creates base roles and permissions'
  task seed: 'environment' do
    Role.ensure_exists(Role::USER_ROLE) do |role|
      role.ensure_permission_exists(
        :view,
        applies_to: 'User',
        states: ['*']
      )
    end

    Role.ensure_exists(Role::SITE_ADMIN_ROLE) do |role|
      role.ensure_permission_exists(Permission::WILDCARD, applies_to: 'System')
    end

    Journal.all.each do |journal|
      # JournalFactory is used to set up new journals. Rather than
      # duplicate logic just expose the step that ensures journals are
      # set up baseline roles and permissions.
      JournalFactory.ensure_default_roles_and_permissions_exist(journal)
      JournalFactory.assign_hints(journal)
    end
  end
end
