require 'rails_helper'

describe PermissionsController do
  include AuthorizationSpecHelper

  let(:user) { FactoryGirl.create :user }
  let(:journal) do
    FactoryGirl.create(
      :journal,
      :with_creator_role,
      :with_production_staff_role
    )
  end
  let!(:paper) { FactoryGirl.create :paper, journal: journal }

  before { sign_in user }

  describe '#show' do
    context 'has one assignment to the object' do
      let!(:withdraw_permission_for_creator_role) do
        journal.creator_role.ensure_permission_exists(
          :withdraw,
          applies_to: 'Paper',
          states: ['*']
        )
      end

      context 'as the creator' do
        before do
          assign_user user, to: paper, with_role: journal.creator_role
        end

        it 'returns the permission' do
          get :show, id: "Paper+#{paper.id}"
          expect(response.status).to eq(200)
          expect(res_body['permissions'].count).to eq(1)
          first_permission_for = res_body['permissions'][0]['object']
          expect(first_permission_for['id']).to eq(paper.id)
        end
      end
    end

    context 'has one permission at the journal level' do
      let!(:withdraw_permission_for_production_staff_role) do
        journal.production_staff_role.ensure_permission_exists(
          :withdraw,
          applies_to: 'Paper',
          states: ['*']
        )
      end

      context 'as staff' do
        before do
          assign_user(
            user,
            to: paper.journal,
            with_role: journal.production_staff_role
          )
        end

        it 'returns the permission' do
          get :show, id: "Paper+#{paper.id}"
          expect(response.status).to eq(200)
          expect(res_body['permissions'].count).to eq(1)
          first_permission_for = res_body['permissions'][0]['object']
          expect(first_permission_for['id']).to eq(paper.id)
        end
      end
    end
  end
end
