require 'rails_helper'

describe 'SeedHelpers' do
  let(:journal) { FactoryGirl.create(:journal) }

  describe 'Role#ensure' do
    it 'creates a role' do
      role_q = Role.where(name: 'role')
      expect(role_q).not_to exist
      Role.ensure('role')
      expect(role_q).to exist
    end

    it 'set participates_in_*' do
      role = Role.ensure('role', participates_in: [Task, Paper])
      role.reload
      expect(role.participates_in_tasks).to be(true)
      expect(role.participates_in_papers).to be(true)
    end

    it 'does not allow bad participates_in_*' do
      expect { Role.ensure('role', participates_in: [String]) }
        .to raise_error(StandardError, /Bad participates_in/)
    end

    it 'yields the new role' do
      Role.ensure('role') do |role|
        expect(role).to eq(Role.where(name: 'role').first)
      end
    end

    it 'sets the journal if provided' do
      role = Role.ensure('role', journal: journal)
      expect(role.reload.journal).to eq(journal)
    end
  end

  describe 'Permission#ensure' do
    it 'creates a permission' do
      perm_q = Permission.where(action: 'view', applies_to: Task)
      expect(perm_q).not_to exist
      Permission.ensure('view', applies_to: Task)
      expect(perm_q).to exist
    end

    it 'sets states' do
      perm = Permission.ensure('view', applies_to: Task, states: ['madness'])
      expect(perm.reload.states.map(&:name)).to match(['madness'])
    end

    it 'sets states to [*] by default' do
      perm = Permission.ensure('view', applies_to: Task)
      expect(perm.reload.states.map(&:name)).to match(['*'])
    end

    it 'sets role' do
      Role.ensure('role') do |role|
        perm = Permission.ensure('view', role: role, applies_to: Task)
        expect(perm.reload.roles).to match([role])
      end
    end
  end
end
