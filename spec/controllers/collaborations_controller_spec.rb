require 'rails_helper'
require 'sidekiq/testing'

describe CollaborationsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:collaborator) { FactoryGirl.create(:user) }
  let(:paper) do
    FactoryGirl.create(:paper, creator: user, journal: journal)
  end
  let(:journal) do
    FactoryGirl.create(
      :journal,
      :with_creator_role,
      :with_collaborator_role
    )
  end

  describe '#create' do
    subject(:do_request) do
      post :create, params: { format: :json, collaboration: collaborator_params }
    end

    let(:collaborator_params) do
      { user_id: collaborator.id, paper_id: paper.id }
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user has access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:manage_collaborators, paper)
          .and_return true
      end

      it 'adds the user as a collaborator on the paper' do
        expect do
          do_request
        end.to change(paper.assignments, :count).by(1)

        expect(paper.assignments.find_by(
                 role: paper.journal.collaborator_role,
                 user: collaborator
        )).to be
      end

      it 'adds activities to the feeds' do
        expect do
          post :create, params: { format: :json, collaboration: collaborator_params }
        end.to change(Activity, :count).by(1)
      end

      it 'adds an email to the sidekiq queue' do
        expect do
          post :create, params: { format: :json, collaboration: collaborator_params }
        end.to change(Sidekiq::Extensions::DelayedMailer.jobs, :size).by(1)
        expect(UserMailer).to receive(:add_collaborator).with(user.id, collaborator.id, paper.id).and_call_original
        Sidekiq::Extensions::DelayedMailer.drain
      end
    end

    context 'when the user does not have access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:manage_collaborators, paper)
          .and_return false
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe '#destroy' do
    subject(:do_request) do
      delete :destroy, params: { format: :json, id: collaboration.id }
    end

    let!(:collaboration) { paper.add_collaboration(collaborator) }

    it_behaves_like 'an unauthenticated json request'

    context 'when the user has access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:manage_collaborators, paper)
          .and_return true
      end

      it 'removes collaboration from the paper' do
        expect do
          do_request
        end.to change(paper.assignments, :count).by(-1)

        expect(paper.assignments.find_by(
                 role: paper.journal.collaborator_role,
                 user: collaborator
        )).to_not be
      end

      it 'adds activities to the feeds' do
        expect do
          delete :destroy, params: { format: :json, id: collaboration.id }
        end.to change(Activity, :count).by(1)
      end
    end

    context 'when the user does not have access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:manage_collaborators, paper)
          .and_return false
      end

      it { is_expected.to responds_with(403) }
    end
  end
end
