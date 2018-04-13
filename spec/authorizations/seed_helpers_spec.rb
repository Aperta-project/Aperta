# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

require 'rails_helper'

describe 'SeedHelpers' do
  let!(:journal) { FactoryGirl.create(:journal) }

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

    describe 'removing unused permissions from the role' do
      context 'without custom card permissions' do
        it 'removes unused permissions from the role' do
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

      context 'with custom card permissions' do
        let!(:card) { FactoryGirl.create(:card, journal: journal) }

        it 'does not remove custom card permissions' do
          # add one Task role and one Card role, and ensure both are there
          Role.ensure_exists('role', journal: journal) do |role|
            role.ensure_permission_exists(:view, applies_to: Task, states: ['*'])
          end
          CardPermissions.add_roles(card, :view, [Role.find_by(name: 'role')])
          aggregate_failures do
            applied_permissions = Permission.joins(:roles).where(roles: { name: 'role' })
            expect(applied_permissions.count).to eq(2)
            expect(applied_permissions.custom_card.count).to eq(1)
            expect(applied_permissions.non_custom_card.count).to eq(1)
          end

          # assign new permissions for the Task
          Role.ensure_exists('role', journal: journal) do |role|
            role.ensure_permission_exists(:view, applies_to: Task, states: ['*'])
          end

          # and ensure that permissions for the Card are NOT destroyed
          aggregate_failures do
            applied_permissions = Permission.joins(:roles).where(roles: { name: 'role' })
            expect(applied_permissions.count).to eq(2)
            expect(applied_permissions.custom_card.count).to eq(1)
            expect(applied_permissions.non_custom_card.count).to eq(1)
          end
        end
      end
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

    it 'creates a new permission for the set of states' do
      first = Permission.ensure_exists('view', applies_to: Task,
                                               states: ['one', 'two'])
      second = Permission.ensure_exists('view', applies_to: Task,
                                                states: ['two', 'three'])
      expect(first.states.reload.map(&:name)).to contain_exactly('one', 'two')
      expect(second.states.reload.map(&:name)).to contain_exactly('two', 'three')
      expect(first).not_to eq(second)
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

    it 'does not allow creating a CustomCardPermission with a nil filter_by_card_id' do
      expect do
        role.ensure_permission_exists(:view, applies_to: CustomCardTask)
      end.to raise_exception(ActiveRecord::RecordInvalid, /Filter by card can't be blank/)
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
