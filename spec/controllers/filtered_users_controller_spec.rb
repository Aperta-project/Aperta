require 'rails_helper'

describe FilteredUsersController do
  let(:user) { FactoryGirl.create :user }
  let(:journal) { FactoryGirl.create(:journal) }
  let(:paper) { FactoryGirl.create :paper, journal: journal }
  let(:task) { FactoryGirl.create :ad_hoc_task, paper: paper }

  describe "#users" do
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
        expect(res_body['users'].count).to eq(1)
        expect(res_body['users'][0]['username']).to eq('UserName')
      end
    end
  end

  describe '#assignable_users' do
    let(:assignable_user) do
      FactoryGirl.build_stubbed(:user, username: 'FooBar')
    end
    let(:eligible_users) do
      [FactoryGirl.build_stubbed(:user, username: 'Foo'), assignable_user]
    end

    subject(:do_request) do
      get(:assignable_users, format: 'json', task_id: task.to_param, query: 'Foo')
    end
    before do
      stub_sign_in(user)
      allow(User).to receive(:fuzzy_search)
                      .with('Foo')
                      .and_return eligible_users
      allow(User).to receive(:who_can)
                      .with('be_assigned', task)
                      .and_return [assignable_user]
      do_request
    end

    it 'returns a list of users who can be assigned to a task' do
      expect(res_body['users'].count).to eq(1)
      expect(res_body['users'][0]['username']).to eq('FooBar')
    end
  end
end
