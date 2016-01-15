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

    permission = Permission.where(
      action: :view,
      applies_to: 'Task'
    ).first_or_create!

    role = Role.where(
      name: 'Author',
      participates_in_tasks: true,
      journal_id: nil # this role is not bound to a Journal
    ).first_or_create!
    role.permissions = (role.permissions + [permission]).uniq

    permission = Permission.where(
      action: :view,
      applies_to: 'Paper'
    ).first_or_create!
    role.permissions = (role.permissions + [permission]).uniq
    role.save

    Permission.last.states << PermissionState.first
    Permission.last.save

    permission = Permission.where(
      action: :view,
      applies_to: 'Task'
    ).first_or_create!

    role = Role.where(
      name: 'Reviewer',
      participates_in_tasks: true,
      journal_id: nil # this role is not bound to a Journal
    ).first_or_create!
    role.permissions = (role.permissions + [permission]).uniq

    permission = Permission.where(
      action: :view,
      applies_to: 'Paper'
    ).first_or_create!
    role.permissions = (role.permissions + [permission]).uniq

    Permission.last.states << PermissionState.first
    Permission.last.save

    # Assignment.create(
    #  user: User.first,
    #  role: Role.where(name: 'Author').first,
    #  assigned_to: User.first.papers.first
    # )
  end
end
