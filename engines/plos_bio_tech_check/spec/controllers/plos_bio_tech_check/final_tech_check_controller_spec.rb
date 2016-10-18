require 'rails_helper'

describe PlosBioTechCheck::FinalTechCheckController do
  routes { PlosBioTechCheck::Engine.routes }

  let(:user) { FactoryGirl.build_stubbed :user }
  let(:task) { FactoryGirl.build_stubbed :final_tech_check_task }

  describe '#send_email' do
    subject(:do_request) do
      post :send_email, id: task.id, format: :json
    end

    before do
      allow(PlosBioTechCheck::FinalTechCheckTask).to receive(:find)
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
        allow(task).to receive(:notify_author_of_changes!)
      end

      it 'tells the task to notify the author of changes' do
        expect(task).to receive(:notify_author_of_changes!)
          .with(submitted_by: user)
        do_request
      end

      it { is_expected.to responds_with(200) }
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
