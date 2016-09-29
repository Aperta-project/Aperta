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

    describe '#filter_authorized' do
      it 'returns its inputs for a single instance' do
        expect(user.filter_authorized(:view, paper1).objects)
          .to contain_exactly(paper1)
      end

      context 'when a class is passed in' do
        it 'returns no instances by default' do
          query = user.filter_authorized(
            :view,
            Authorizations::FakePaper
          )
          expect(query.objects).to eq([])
        end

        it 'returns no instances when participations_only is true' do
          query = user.filter_authorized(
            :view,
            Authorizations::FakePaper,
            participations_only: true
          )
          expect(query.objects).to eq([])
        end

        it 'returns all instances participations_only is false' do
          query = user.filter_authorized(
            :view,
            Authorizations::FakePaper,
            participations_only: false
          )
          expect(query.objects).to eq(Authorizations::FakePaper.all)
        end
      end

      context 'when a relation is passed in' do
        it 'returns no instances by default' do
          query = user.filter_authorized(
            :view,
            Authorizations::FakePaper.all
          )
          expect(query.objects).to eq([])

          query = user.filter_authorized(
            :view,
            Authorizations::FakePaper.where(id: [paper2.id, paper3.id])
          )
          expect(query.objects).to eq([])
        end

        it 'returns no instances when participations_only is true' do
          query = user.filter_authorized(
            :view,
            Authorizations::FakePaper.all,
            participations_only: true
          )
          expect(query.objects).to eq([])

          query = user.filter_authorized(
            :view,
            Authorizations::FakePaper.where(id: [paper2.id, paper3.id]),
            participations_only: true
          )
          expect(query.objects).to eq([])
        end

        it 'returns all instances when participations_only is false' do
          query = user.filter_authorized(
            :view,
            Authorizations::FakePaper.all,
            participations_only: false
          )
          expect(query.objects).to eq(Authorizations::FakePaper.all)

          query = user.filter_authorized(
            :view,
            Authorizations::FakePaper.where(id: [paper2.id, paper3.id]),
            participations_only: false
          )
          expect(query.objects).to contain_exactly(paper2, paper3)
        end
      end

      context <<-DESC.strip_heredoc do
        when the user assigned to the Site Admin role has another
        assignment that allows them to participate

        This is so that a user can fill dual purposes in the system. E.g.
        a system-level user who has access to everything, but whom participates
        in nothing AND a non-system-level user who may be a participant in a
        paper, task, discussion, etc.
      DESC
        let(:paper_role) { FactoryGirl.create(:role) }

        before do
          paper_role.ensure_permission_exists :view, applies_to: Authorizations::FakePaper
          user.assign_to! assigned_to: paper1, role: paper_role
        end

        it 'returns the records they are participating in' do
          query = user.filter_authorized(
            :view,
            Authorizations::FakePaper.all
          )
          expect(query.objects).to contain_exactly(paper1)

          query = user.filter_authorized(
            :view,
            Authorizations::FakePaper.all,
            participations_only: true
          )
          expect(query.objects).to contain_exactly(paper1)
        end
      end

      it 'generates the correct json' do
        query = user.filter_authorized(:view, paper1)
        expect(query.as_json).to eq(expected_paper_json)
      end
    end
  end
end
