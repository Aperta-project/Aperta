require 'rails_helper'

module PlosBioTechCheck
  describe RevisionTechCheckController do
    routes { Engine.routes }

    let(:user) { FactoryGirl.build_stubbed :user }
    let(:task) { FactoryGirl.build_stubbed :revision_tech_check_task }
    let(:notify_service) do
      instance_double(NotifyAuthorOfChangesNeededService, notify!: nil)
    end

    describe '#send_email' do
      subject(:do_request) do
        post :send_email, id: task.id, format: :json
      end

      before do
        allow(RevisionTechCheckTask).to receive(:find)
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
          allow(NotifyAuthorOfChangesNeededService).to receive(:new)
            .and_return notify_service
        end

        it 'tells notify service to notify the author' do
          allow(NotifyAuthorOfChangesNeededService).to receive(:new)
            .with(task, submitted_by: user)
            .and_return notify_service
          expect(notify_service).to receive(:notify!)
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
end
