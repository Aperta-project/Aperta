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

    Role.ensure_exists('Author') do |role|
      role.ensure_permission_exists(
        :withdraw_manuscript,
        applies_to: 'Paper',
        states: ['*']
      )
    end

    Role.ensure_exists('JournalStaff') do |role|
      role.ensure_permission_exists(
        :withdraw_manuscript,
        applies_to: 'Paper',
        states: ['*']
      )
    end
  end
end
