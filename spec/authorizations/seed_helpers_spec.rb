require 'rails_helper'

describe 'SeedHelpers' do
  let(:journal) { FactoryGirl.create(:journal) }

  before do
    # This is intended to remove the baseline seeds that were created
    # by rails helper. It is safe to clear out since unit tests are
    # wrapped in a transaction
    Role.delete_all
    Permission.delete_all
    PermissionsRole.delete_all
    PermissionState.delete_all
    PermissionStatesPermission.delete_all
  end

  describe 'Role.ensure_exists' do
    it 'creates a role' do
      role_q = Role.where(name: 'role')
      expect(role_q).not_to exist
      Role.ensure_exists('role')
      expect(role_q).to exist
    end

    it 'set participates_in_*' do
      role = Role.ensure_exists('role', participates_in: [Task, Paper])
      role.reload
      expect(role.participates_in_tasks).to be(true)
      expect(role.participates_in_papers).to be(true)
    end

    it 'raises an error when the participaties_in_* column is not present' do
      expect { Role.ensure_exists('role', participates_in: [String]) }
        .to raise_error(
          Authorizations::RoleImporter::MissingColumn,
          /The roles table doesn't have a column named.*'participates_in_strings'/m
        )
    end

    it 'returns the new role' do
      role = Role.ensure_exists('role')
      expect(role).to eq(Role.where(name: 'role').first)
    end

    it 'sets the journal if provided' do
      role = Role.ensure_exists('role', journal: journal)
      expect(role.reload.journal).to eq(journal)
    end

    it 'removes no longer used permissions from the role' do
      Role.ensure_exists('role', journal: journal) do |role|
        role.ensure_permission_exists(:edit, applies_to: Task, states: ['*'])
        role.ensure_permission_exists(:view, applies_to: Task, states: ['*'])
      end
      expect(
        Role.where(name: 'role').first.reload.permissions.map(&:action)
      ).to contain_exactly('view', 'edit')

      Role.ensure_exists('role', journal: journal) do |role|
        role.ensure_permission_exists(:view, applies_to: Task, states: ['*'])
      end
      expect(
        Role.where(name: 'role').first.reload.permissions.map(&:action)
      ).to match(%w(view))

      # The permission should still exist though
      expect(
        Permission.joins(:states).where(
          action: 'edit',
          applies_to: Task,
          permission_states: { id: PermissionState.wildcard }
        )
      ).to exist
    end
  end

  describe 'Permission.ensure_exists' do
    it 'creates a permission' do
      perm_q = Permission.where(action: 'view', applies_to: Task)
      expect(perm_q).not_to exist
      Permission.ensure_exists('view', applies_to: Task)
      expect(perm_q).to exist
    end

    it 'sets states' do
      perm = Permission.ensure_exists('view', applies_to: Task,
                                              states: ['madness'])
      expect(perm.reload.states.map(&:name)).to match(['madness'])
    end

    it 'sets states to [*] by default' do
      perm = Permission.ensure_exists('view', applies_to: Task)
      expect(perm.reload.states.map(&:name)).to match(['*'])
    end

    it 'sets role' do
      role = FactoryGirl.create(:role)
      perm = Permission.ensure_exists('view', role: role, applies_to: Task)
      expect(perm.reload.roles).to match([role])
    end
  end

  describe 'with an existing role' do
    subject!(:role) do
      Role.ensure_exists('Enthuasist').tap do |_role|
        Permission.ensure_exists(:view, role: _role, applies_to: Task)
      end
    end

    it 'can add a new permission' do
      role.ensure_permission_exists(:edit, applies_to: Task)
      permissions = Role.where(name: 'Enthuasist').first.permissions
      expect(permissions).to contain_exactly(
        Permission.where(action: :view, applies_to: Task).first,
        Permission.where(action: :edit, applies_to: Task).first
      )
    end

    it 'does nothing if the permission already exists' do
      expect(role.permissions).to contain_exactly(
        Permission.where(action: :view, applies_to: Task).first)
    end

    it 'adds a new permission if the states do not match' do
      expect do
        role.ensure_permission_exists(
          :view,
          applies_to: Task,
          states: ['madness']
        )
      end.to change { Permission.count }.by(1)

      permission_states = role.permissions.reload.map do |permission|
        permission.states.map(&:name)
      end
      expect(permission_states).to contain_exactly(['*'], ['madness'])
    end
  end
end
