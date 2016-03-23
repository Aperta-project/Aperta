require 'rails_helper'

describe PaperRoleEligibleUsersController do
  let(:user) { FactoryGirl.create :user }
  let(:paper) { FactoryGirl.create(:paper) }
  let(:role) { FactoryGirl.create(:role, journal: paper.journal) }
  let(:json_response) { JSON.parse(response.body).with_indifferent_access }

  before { sign_in(user) }

  describe '#index' do
    subject(:do_request) do
      get(
        :index,
        format: 'json',
        paper_id: paper.to_param,
        role_id: role.to_param,
        query: 'Kangaroo'
      )
    end
    let(:eligible_users) do
      [FactoryGirl.build_stubbed(:user, username: 'IamEligible')]
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user has access' do
      before do
        stub_sign_in(user)

        allow(user).to receive(:can?)
          .with(:view_user_role_eligibility_on_paper, paper)
          .and_return true

        allow(EligibleUserService).to receive(:eligible_users_for)
          .with(paper: paper, role: role, matching: 'Kangaroo')
          .and_return eligible_users
      end

      it { responds_with(200) }

      it 'returns users who are eligible to be assigned to the provided role' do
        do_request
        expect(res_body['users'].count).to eq(1)
        expect(res_body['users'][0]['first_name']).to \
          eq(eligible_users.first.first_name)
      end
    end

    context 'when the user does not have access' do
      before do
        allow(user).to receive(:can?)
          .with(:view_user_role_eligibility_on_paper, paper)
          .and_return false
      end

      it { responds_with(403) }
    end
  end
end
