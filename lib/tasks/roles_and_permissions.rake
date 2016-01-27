namespace :'roles-and-permissions' do
  desc 'Creates base roles and permissions'
  task seed: 'environment' do
    Role.ensure_exists('User') do |role|
      role.ensure_permission_exists(
        :view_profile,
        applies_to: 'User',
        states: ['*']
      )
    end

    Role.ensure_exists('Author', participates_in: [Task, Paper]) do |role|
      role.ensure_permission_exists(:view, applies_to: 'Task')
      role.ensure_permission_exists(:view, applies_to: 'Paper')
      role.ensure_permission_exists(:view, applies_to: 'PlosBilling::BillingTask')
    end

    Role.ensure_exists('Reviewer', participates_in: [Task, Paper]) do |role|
      role.ensure_permission_exists(:view, applies_to: 'Task')
      role.ensure_permission_exists(:view, applies_to: 'Paper')
    end

    Role.ensure_exists('Staff Admin') do |role|
      role.ensure_permission_exists(:administer, applies_to: 'Journal')
      role.ensure_permission_exists(:manage_workflow, applies_to: 'Paper')
      role.ensure_permission_exists(:view, applies_to: 'Paper')
      role.ensure_permission_exists(:view, applies_to: 'Task')
    end
  end
end
