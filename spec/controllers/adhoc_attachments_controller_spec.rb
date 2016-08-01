require 'rails_helper'

describe AdhocAttachmentsController do
  let(:user) { FactoryGirl.create :user }
  let(:journal) { FactoryGirl.create(:journal, :with_creator_role) }
  let(:paper) { FactoryGirl.create(:paper, journal: journal, creator: user) }
  let(:task) { FactoryGirl.create(:task, paper: paper) }

  describe 'GET #index' do
    subject(:do_request) { get :index, format: 'json', task_id: task.to_param }

    it_behaves_like 'an unauthenticated json request'

    context 'when the user is signed in' do
      before do
        task.attachments.create!
        task.attachments.create!

        stub_sign_in user
      end

      context 'when the user has access' do
        before do
          allow(user).to receive(:can?)
            .with(:view, task)
            .and_return true
        end

        it 'responds with a list of attachments' do
          do_request
          expect(res_body['attachments'].length).to eq(task.attachments.length)
        end

        it 'returns 200 OK' do
          do_request
          expect(response.status).to eq(200)
        end
      end

      context 'when the user does not have access' do
        before do
          allow(user).to receive(:can?)
            .with(:view, task)
            .and_return false
        end

        it 'returns a 403' do
          do_request
          expect(response.status).to eq(403)
        end
      end
    end
  end

  describe 'GET #show' do
    let(:attachment) { task.attachments.create! }

    subject(:do_request) do
      get :show, format: 'json', task_id: task.to_param, id: attachment.to_param
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user is signed in' do
      before do
        stub_sign_in user
      end

      context 'when the user has access' do
        before do
          allow(user).to receive(:can?)
            .with(:view, task)
            .and_return true
        end

        it 'responds with the attachment' do
          do_request
          expect(res_body['attachment']['id']).to eq(attachment.id)
        end

        it 'returns 200 OK' do
          do_request
          expect(response.status).to eq(200)
        end
      end

      context 'when the user does not have access' do
        before do
          allow(user).to receive(:can?)
            .with(:view, task)
            .and_return false
        end

        it 'returns a 403' do
          do_request
          expect(response.status).to eq(403)
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    subject(:do_request) do
      xhr :delete, :destroy, id: task.attachments.last.id, paper_id: paper.id
    end

    before do
      task.attachments.create!
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user is signed in' do
      before { stub_sign_in user }

      context 'when the user has access' do
        before do
          allow(user).to receive(:can?)
            .with(:edit, task)
            .and_return true
        end

        it 'destroys the attachment record' do
          expect { do_request }.to change { AdhocAttachment.count }.by(-1)
        end
      end

      context 'when the user does not have access' do
        before do
          allow(user).to receive(:can?)
            .with(:edit, task)
            .and_return false
        end

        it 'does not destroy the attachment' do
          expect { do_request }.to change { AdhocAttachment.count }.by(0)
        end

        it 'returns a 403' do
          do_request
          expect(response.status).to eq(403)
        end
      end
    end
  end

  describe 'POST #create' do
    subject(:do_request) do
      post :create, format: 'json', task_id: task.to_param, title: 'Cool'
    end
    let(:url) { 'http://someawesomeurl.com' }

    it_behaves_like 'an unauthenticated json request'

    context 'when the user is signed in' do
      before { stub_sign_in user }

      context 'when the user has access' do
        before do
          allow(user).to receive(:can?)
            .with(:edit, task)
            .and_return true
        end

        it 'causes the creation of the attachment' do
          expect(DownloadAttachmentWorker).to receive(:perform_async)
          do_request
          expect(response).to be_success
        end
      end

      context 'when the user does not have access' do
        before do
          allow(user).to receive(:can?)
            .with(:edit, task)
            .and_return false
        end

        it 'returns a 403' do
          do_request
          expect(response.status).to eq(403)
        end
      end
    end
  end

  describe 'PUT #update_attachment' do
    subject(:do_request) do
      put :update_attachment, format: 'json', task_id: task.to_param, id: attachment.id, url: url
    end

    let(:url) { "http://someawesomeurl.com" }
    let(:attachment) { task.attachments.create! }

    it_behaves_like 'an unauthenticated json request'

    context 'when the user is signed in' do
      before { stub_sign_in user }

      context 'when the user has access' do
        before do
          allow(user).to receive(:can?)
            .with(:edit, task)
            .and_return true
        end

        it 'calls DownloadAttachmentWorker' do
          expect(DownloadAttachmentWorker).to receive(:perform_async).with(attachment.id, url)
          do_request
          expect(response).to be_success
        end
      end

      context 'when the user does not have access' do
        before do
          allow(user).to receive(:can?)
            .with(:edit, task)
            .and_return false
        end

        it 'returns a 403' do
          do_request
          expect(response.status).to eq(403)
        end
      end
    end
  end

  describe 'PUT #update' do
    subject(:do_request) do
      patch :update,
            id: task.attachments.last.id,
            task_id: task.id,
            attachment: {
              title: "new title",
              caption: "new caption"
            },
            format: :json
    end

    before do
      task.attachments.create!
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user is signed in' do
      before { stub_sign_in user }

      context 'when the user has access' do
        before do
          allow(user).to receive(:can?)
            .with(:edit, task)
            .and_return true
        end

        it 'allows updates for title and caption' do
          do_request

          attachment = task.attachments.last
          expect(attachment.caption).to eq('new caption')
          expect(attachment.title).to eq('new title')
        end
      end

      context 'when the user does not have access' do
        before do
          allow(user).to receive(:can?)
            .with(:edit, task)
            .and_return false
        end

        it 'returns a 403' do
          do_request
          expect(response.status).to eq(403)
        end
      end
    end
  end
end
