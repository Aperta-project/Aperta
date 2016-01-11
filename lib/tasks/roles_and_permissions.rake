namespace :'roles-and-permissions' do
  desc 'Creates base roles and permissions'
  task seed: 'environment' do
    state = State.where(name: '*').first_or_create!
    permission = Permission.where(
      action: :view_profile,
      applies_to: 'User'
    ).first_or_create!
    permission.states = (permission.states + [state]).uniq

    role = Role.where(
      name: 'User',
      journal_id: nil # this role is not bound to a Journal
    ).first_or_create!
    role.permissions = (role.permissions + [permission]).uniq
  end
end
