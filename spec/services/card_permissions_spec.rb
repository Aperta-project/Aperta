require 'rails_helper'

describe CardPermissions do
  let(:journal) { FactoryGirl.create(:journal) }
  let(:user) { FactoryGirl.create(:user) }
  let(:card) { FactoryGirl.create(:card, journal: journal) }
  let(:role) { FactoryGirl.create(:role, journal: journal, name: Faker::Name.title) }
  let(:query) { { action: 'eat', applies_to: 'Task', filter_by_card_id: card.id } }

  shared_examples_for "permission creator" do
    it "should create 4 permissions" do
      expect do
        subject
      end.to change { Permission.all.count }.from(0).to(4)
    end

    it "should create a new permission with a wildcard state" do
      subject
      expect(role.permissions.find_by(query)).to be
      expect(role.permissions.find_by(query).applies_to).to eq('Task')
    end

    it 'should create a view permission on the CardVersion' do
      subject
      expect(role.permissions.where(action: 'view', applies_to: 'CardVersion', filter_by_card_id: card.id).count).to be(1)
    end

    it 'should return the permissions' do
      expect(subject).to contain_exactly(*Permission.where(applies_to: 'Task'))
    end
  end

  describe ".add_roles" do
    subject { CardPermissions.add_roles(card, "eat", [role]) }

    it_should_behave_like "permission creator"

    context 'when the permission already exists' do
      let!(:permission) do
        Permission.ensure_exists(
          'eat',
          applies_to: 'Task',
          role: role,
          states: [Permission::WILDCARD],
          filter_by_card_id: card.id
        )
      end
      let(:new_role) { FactoryGirl.create(:role, journal: journal, name: Faker::Name.title) }

      it 'adds the new role' do
        CardPermissions.add_roles(card, "eat", [new_role])
        expect(role.reload.permissions.reload.where(query).count).to be(1)
        expect(new_role.permissions.reload.where(query).count).to be(1)
      end
    end

    context 'when the role is creator' do
      let(:role) { FactoryGirl.create(:role, journal: journal, name: 'Creator') }

      it "should assign the role to limted states permission" do
        subject
        perm = role.permissions.where(action: 'eat').first
        expect(perm.states.pluck(:name)).to contain_exactly(*Paper::EDITABLE_STATES.map(&:to_s))
      end
    end

    context 'when the role is a collaborator' do
      let(:role) { FactoryGirl.create(:role, journal: journal, name: 'Collaborator') }

      it "should assign the role to editable states permission" do
        subject
        perm = role.permissions.where(action: 'eat').first
        expect(perm.states.pluck(:name)).to contain_exactly(*Paper::EDITABLE_STATES.map(&:to_s))
      end
    end

    context 'when the role is a reviewer' do
      let(:role) { FactoryGirl.create(:role, journal: journal, name: 'Reviewer') }

      it "should assign the role to editable states permission" do
        subject
        perm = role.permissions.where(action: 'eat').first
        expect(perm.states.pluck(:name)).to contain_exactly(*Paper::REVIEWABLE_STATES.map(&:to_s))
      end
    end
  end

  describe '.set_roles' do
    subject { CardPermissions.set_roles(card, "eat", [role]) }

    it_should_behave_like "permission creator"

    context 'when the permission already exists' do
      let!(:permission) do
        Permission.ensure_exists(
          'eat',
          applies_to: 'Task',
          role: role,
          states: [Permission::WILDCARD]
        )
      end
      let(:new_role) { FactoryGirl.create(:role, journal: journal, name: Faker::Name.title) }

      it 'adds the new role and removes the old' do
        CardPermissions.set_roles(card, "eat", [new_role])
        expect(role.permissions.where(query).count).to be(0)
        expect(new_role.permissions.where(query).count).to be(1)
      end
    end
  end
end
