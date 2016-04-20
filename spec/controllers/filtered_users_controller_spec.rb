require 'rails_helper'

describe FilteredUsersController do
  describe "#users" do
    let(:user) { FactoryGirl.create :user }
    let(:journal) { FactoryGirl.create(:journal) }
    let(:paper) { FactoryGirl.create :paper, journal: journal }
    subject(:do_request) do
      get(
        :users,
        format: 'json',
        paper_id: paper.to_param,
        query: 'Kangaroo'
      )
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user is signed in' do
      let(:eligible_users) do
        [FactoryGirl.build_stubbed(:user, username: 'UserName')]
      end
      before do
        stub_sign_in(user)
        allow(User).to receive(:fuzzy_search)
          .with('Kangaroo')
          .and_return eligible_users

        do_request
      end

      it { is_expected.to responds_with(200) }

      it 'returns any user who matches the query' do
        expect(res_body['filtered_users'].count).to eq(1)
        expect(res_body['filtered_users'][0]['username']).to eq('UserName')
      end
    end
  end
end
