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

    Role.ensure_exists('Author', participates_in: [Task]) do |role|
      role.ensure_permission_exists(:view, applies_to: 'Task')
      role.ensure_permission_exists(:view, applies_to: 'Paper')
    end

    Role.ensure_exists('Reviewer', participates_in: [Task]) do |role|
      role.ensure_permission_exists(:view, applies_to: 'Task')
      role.ensure_permission_exists(:view, applies_to: 'Paper')
    end

    # Assignment.create(
    #  user: User.first,
    #  role: Role.where(name: 'Author').first,
    #  assigned_to: User.first.papers.first
    # )
  end
end
