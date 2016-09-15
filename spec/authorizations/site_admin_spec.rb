require 'rails_helper'

describe 'Site admins have ALL the permissions' do
  include AuthorizationSpecHelper

  let!(:user) { FactoryGirl.create(:user) }

  let!(:the_system) { System.create! }

  let!(:site_admin_role) do
    Role.ensure_exists(Role::SITE_ADMIN_ROLE) do |role|
      role.ensure_permission_exists(Permission::WILDCARD, applies_to: 'System')
    end
  end

  let!(:paper1) { Authorizations::FakePaper.create! }
  let!(:paper2) { Authorizations::FakePaper.create! }
  let!(:paper3) { Authorizations::FakePaper.create! }
  let!(:paper4) { Authorizations::FakePaper.create! }

  let(:expected_paper_json) do
    [{
      object: { id: paper1.id, type: 'Authorizations::FakePaper' },
      permissions: { view: { states: ['*'] } },
      id: "fakePaper+#{paper1.id}"
    }].as_json
  end

  before(:all) do
    Authorizations.reset_configuration
    AuthorizationModelsSpecHelper.create_db_tables
    Permission.ensure_exists(:view, applies_to: Authorizations::FakePaper)
  end

  context 'when the user is a site admin' do
    before do
      user.assign_to! assigned_to: the_system, role: Role.site_admin_role
    end

    describe 'they can?' do
      it 'do anything' do
        expect(user.can?(:view, paper1)).to eq(true)
        expect(user.can?(:anything, paper1)).to eq(true)
        expect(user.can?(:really_any_thing, paper1)).to eq(true)
      end
    end

    describe 'filter_authorized' do
      it 'returns its inputs for a single instance' do
        expect(user.filter_authorized(:view, paper1).objects)
          .to contain_exactly(paper1)
      end

      it 'returns all instances when a class is passed in' do
        query = user.filter_authorized(:view, Authorizations::FakePaper)
        expect(query.objects).to eq(Authorizations::FakePaper.all)
      end

      it 'returns the same instances when a relation is passed in' do
        query = user.filter_authorized(:view, Authorizations::FakePaper.all)
        expect(query.objects).to eq(Authorizations::FakePaper.all)

        query = user.filter_authorized(
          :view,
          Authorizations::FakePaper.where(id: [paper2.id, paper3.id])
        )
        expect(query.objects).to contain_exactly(paper2, paper3)
      end

      it 'generates the correct json' do
        query = user.filter_authorized(:view, paper1)
        expect(query.as_json).to eq(expected_paper_json)
      end
    end
  end
end
