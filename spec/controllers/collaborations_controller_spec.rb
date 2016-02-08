# rubocop:disable Style/FirstParameterIndentation

require 'rails_helper'
require 'sidekiq/testing'

describe CollaborationsController do
  describe '#create' do
    subject(:do_request) do
      post :create, format: :json, collaboration: collaborator_params
    end
    let(:user) { FactoryGirl.create(:user) }
    let(:collaborator) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create(:paper, creator: user) }
    let(:collaborator_params) do
      { user_id: collaborator.id, paper_id: paper.id }
    end

    before { sign_in user }

    context 'when the user has access' do
      before do
        allow_any_instance_of(User).to receive(:can?)
          .with(:edit, paper)
          .and_return true
      end

      it 'adds the user as a collaborator on the paper' do
        expect do
          do_request
        end.to change(paper.assignments, :count).by(1)

        expect(paper.assignments.find_by(
          role: paper.journal.roles.collaborator,
          user: collaborator
        )).to be
      end

      it 'adds the user as a collaborator using paper role' do
        expect do
          do_request
        end.to change(PaperRole, :count).by(1)

        expect(PaperRole.find_by(
          paper: paper,
          user: collaborator,
          old_role: PaperRole::COLLABORATOR
        )).to be
      end

      it 'adds activities to the feeds' do
        expect do
          post :create, format: :json, collaboration: collaborator_params
        end.to change(Activity, :count).by(1)
      end

      it 'adds an email to the sidekiq queue' do
        expect do
          post :create, format: :json, collaboration: collaborator_params
        end.to change(Sidekiq::Extensions::DelayedMailer.jobs, :size).by(1)
      end
    end

    context 'when the user does not have access' do
      before do
        allow_any_instance_of(User).to receive(:can?)
          .with(:edit, paper)
          .and_return false
      end

      it { responds_with(403) }
    end
  end

  describe '#destroy' do
    subject(:do_request) do
      delete :destroy, format: :json, id: collaboration.id
    end
    let(:user) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create(:paper, creator: user) }
    let(:collaborator) { FactoryGirl.create(:user) }
    let!(:collaboration) { paper.add_collaboration(collaborator) }

    before { sign_in user }

    context 'when the user has access' do
      before do
        allow_any_instance_of(User).to receive(:can?)
          .with(:edit, paper)
          .and_return true
      end

      it 'removes collaboration from the paper' do
        expect do
          do_request
        end.to change(paper.assignments, :count).by(-1)

        expect(paper.assignments.find_by(
          role: paper.journal.roles.collaborator,
          user: collaborator
        )).to_not be
      end

      it 'removes the remove as a collaborator using paper role' do
        PaperRole.create!(
          paper: paper,
          user: collaborator,
          old_role: PaperRole::COLLABORATOR
        )
        expect do
          do_request
        end.to change(PaperRole, :count).by(-1)

        expect(PaperRole.find_by(
          paper: paper,
          user: collaborator,
          old_role: PaperRole::COLLABORATOR
        )).to_not be
      end

      it 'adds activities to the feeds' do
        expect do
          delete :destroy, format: :json, id: collaboration.id
        end.to change(Activity, :count).by(1)
      end
    end

    context 'when the user does not have access' do
      before do
        allow_any_instance_of(User).to receive(:can?)
          .with(:edit, paper)
          .and_return false
      end

      it { responds_with(403) }
    end
  end
end
