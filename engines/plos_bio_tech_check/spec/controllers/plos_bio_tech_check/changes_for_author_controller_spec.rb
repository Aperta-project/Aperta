require 'rails_helper'

describe PlosBioTechCheck::ChangesForAuthorController do
  let(:user) { FactoryGirl.build_stubbed :user }
  let(:paper) { FactoryGirl.build_stubbed :paper }
  let(:task) do
    FactoryGirl.build_stubbed(
      :changes_for_author_task,
      paper: paper
    )
  end

  before do
    @routes = PlosBioTechCheck::Engine.routes
  end

  describe 'POST #submit_tech_check' do
    subject(:do_request) do
      post :submit_tech_check, { id: task.to_param, format: 'json' }
    end

    before do
      allow(Task).to receive(:find)
        .with(task.to_param)
        .and_return task
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user has access' do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:edit, task)
          .and_return true
        allow(task).to receive(:submit_tech_check!)
          .and_return true
      end

      it 'submits the tech check' do
        expect(task).to receive(:submit_tech_check!)
          .with(submitted_by: user)
          .and_return true
        do_request
      end

      context 'and the tech check completes successfully' do
        it { is_expected.to responds_with(200) }
      end

      context 'and the tech check is not submitted successfully' do
        before do
          expect(task).to receive(:submit_tech_check!)
            .with(submitted_by: user)
            .and_return false
        end

        it { is_expected.to responds_with(422) }
      end
    end

    context 'when the user does not have access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, task)
          .and_return false
      end

      it { is_expected.to responds_with(403) }
    end
  end
end
