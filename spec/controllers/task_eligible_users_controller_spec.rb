require 'rails_helper'

describe TaskEligibleUsersController do
  let(:user) { FactoryGirl.create :user }
  let(:paper) { FactoryGirl.create :paper, journal: journal }
  let(:task) { FactoryGirl.create :task, paper: paper }

  describe "#academic_editors" do
    let(:journal) do
      FactoryGirl.create(:journal).tap do |journal|
        journal.roles.create!(name: Role::ACADEMIC_EDITOR_ROLE)
      end
    end
    subject(:do_request) do
      get(
        :academic_editors,
        format: 'json',
        task_id: task.to_param,
        query: 'Kangaroo'
      )
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user has access and there are eligible academic editors' do
      let(:eligible_users) do
        [FactoryGirl.build_stubbed(:user, email: 'foo@example.com')]
      end
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:edit, task)
          .and_return true

        allow(EligibleUserService).to receive(:eligible_users_for)
          .with(paper: paper, role: journal.academic_editor_role, matching: 'Kangaroo')
          .and_return eligible_users
        do_request
      end

      it { is_expected.to responds_with(200) }

      it 'returns users who are eligible to be assigned to the provided role' do
        expect(res_body['users'].count).to eq(1)
        expect(res_body['users'][0]['email']).to eq('foo@example.com')
      end
    end

    context 'when the user does not have access' do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:edit, task)
          .and_return false
        do_request
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe "#admins" do
    let(:journal) do
      FactoryGirl.create(:journal).tap do |journal|
        journal.roles.create!(name: Role::STAFF_ADMIN_ROLE)
      end
    end
    subject(:do_request) do
      get(
        :admins,
        format: 'json',
        task_id: task.to_param,
        query: 'Kangaroo'
      )
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user has access and there are eligible staff admins' do
      let(:eligible_users) do
        [FactoryGirl.build_stubbed(:user, email: 'foo@example.com')]
      end
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:edit, task)
          .and_return true

        allow(EligibleUserService).to receive(:eligible_users_for)
          .with(paper: paper, role: journal.staff_admin_role, matching: 'Kangaroo')
          .and_return eligible_users
        do_request
      end

      it { is_expected.to responds_with(200) }

      it 'returns users who are eligible to be assigned to the provided role' do
        expect(res_body['users'].count).to eq(1)
        expect(res_body['users'][0]['email']).to eq('foo@example.com')
      end
    end

    context 'when the user does not have access' do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:edit, task)
          .and_return false
        do_request
      end

      it { is_expected.to responds_with(403) }
    end
  end
  describe "#reviewers" do
    let(:journal) { FactoryGirl.create(:journal) }
    subject(:do_request) do
      get(
        :reviewers,
        format: 'json',
        task_id: task.to_param,
        query: 'Kangaroo'
      )
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user has access' do
      let(:eligible_users) do
        [FactoryGirl.build_stubbed(:user, email: 'foo@example.com')]
      end
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:edit, task)
          .and_return true
        allow(User).to receive(:fuzzy_search)
          .with('Kangaroo')
          .and_return eligible_users

        do_request
      end

      it { is_expected.to responds_with(200) }

      it 'returns any user who matches the query' do
        expect(res_body['users'].count).to eq(1)
        expect(res_body['users'][0]['email']).to eq('foo@example.com')
      end
    end

    context 'when the user does not have access' do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:edit, task)
          .and_return false
        do_request
      end

      it { is_expected.to responds_with(403) }
    end
  end
end
