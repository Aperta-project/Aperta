require 'rails_helper'

describe PermissionsController do
  include AuthorizationSpecHelper

  let(:user) { FactoryGirl.create :user }
  let(:paper) { FactoryGirl.create :paper }

  before { sign_in user }

  describe '#show' do
    permission action: :withdraw_manuscript, applies_to: 'Paper', states: ['*']
    role 'Author' do
      has_permission action: 'withdraw_manuscript', applies_to: 'Paper'
    end
    role 'JournalStaff' do
      has_permission action: 'withdraw_manuscript', applies_to: 'Paper'
    end

    context 'has one assignment to the object' do
      context 'as the author' do
        before do
          assign_user user, to: paper, with_role: role_Author
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
      context 'as the author' do
        before do
          assign_user user, to: paper.journal, with_role: role_JournalStaff
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
