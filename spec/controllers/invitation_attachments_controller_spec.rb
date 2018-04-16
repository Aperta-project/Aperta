# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

require 'rails_helper'

describe InvitationAttachmentsController do
  let(:user) { FactoryGirl.create :user }
  let(:journal) { FactoryGirl.create(:journal, :with_creator_role) }
  let(:paper) { FactoryGirl.create(:paper, journal: journal, creator: user) }
  let(:task) { FactoryGirl.create(:ad_hoc_task, paper: paper) }
  let(:invitation) { FactoryGirl.create(:invitation, task: task) }

  describe 'GET #index' do
    subject(:do_request) { get :index, format: 'json', invitation_id: invitation.to_param }

    it_behaves_like 'an unauthenticated json request'

    context 'when the user is signed in' do
      before do
        invitation.attachments.create!
        invitation.attachments.create!

        stub_sign_in user
      end

      context 'when the user has access' do
        before do
          allow(user).to receive(:can?)
            .with(:manage_invitations, task)
            .and_return true
        end

        it 'responds with a list of attachments' do
          do_request
          expect(res_body['attachments'].length).to eq(invitation.attachments.length)
        end

        it 'returns 200 OK' do
          do_request
          expect(response.status).to eq(200)
        end
      end

      context 'when the user does not have access' do
        before do
          allow(user).to receive(:can?)
            .with(:manage_invitations, task)
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
    let(:attachment) { invitation.attachments.create! }

    subject(:do_request) do
      get :show, format: 'json', invitation_id: invitation.to_param, id: attachment.to_param
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user is signed in' do
      before do
        stub_sign_in user
      end

      context 'when the user has access' do
        before do
          allow(user).to receive(:can?)
            .with(:manage_invitations, task)
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
            .with(:manage_invitations, task)
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
      xhr :delete, :destroy, id: invitation.attachments.last.id, invitation_id: invitation.id
    end

    before do
      invitation.attachments.create!
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user is signed in' do
      before { stub_sign_in user }

      context 'when the user has access' do
        before do
          allow(user).to receive(:can?)
            .with(:manage_invitations, task)
            .and_return true
        end

        it 'destroys the attachment record' do
          expect { do_request }.to change { InvitationAttachment.count }.by(-1)
        end
      end

      context 'when the user does not have access' do
        before do
          allow(user).to receive(:can?)
            .with(:manage_invitations, task)
            .and_return false
        end

        it 'does not destroy the attachment' do
          expect { do_request }.to change { InvitationAttachment.count }.by(0)
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
      post :create, format: 'json', invitation_id: invitation.to_param, title: 'Cool'
    end
    let(:url) { 'http://someawesomeurl.com' }

    it_behaves_like 'an unauthenticated json request'

    context 'when the user is signed in' do
      before { stub_sign_in user }

      context 'when the user has access' do
        before do
          allow(user).to receive(:can?)
            .with(:manage_invitations, task)
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
            .with(:manage_invitations, task)
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
      put :update_attachment, format: 'json', invitation_id: invitation.to_param, id: attachment.id, url: url
    end

    let(:url) { "http://someawesomeurl.com" }
    let(:attachment) { invitation.attachments.create! }

    it_behaves_like 'an unauthenticated json request'

    context 'when the user is signed in' do
      before { stub_sign_in user }

      context 'when the user has access' do
        before do
          allow(user).to receive(:can?)
            .with(:manage_invitations, task)
            .and_return true
        end

        it 'calls DownloadAttachmentWorker' do
          expect(DownloadAttachmentWorker).to receive(:perform_async)
            .with(attachment.id, url, user.id)
          do_request
          expect(response).to be_success
        end
      end

      context 'when the user does not have access' do
        before do
          allow(user).to receive(:can?)
            .with(:manage_invitations, task)
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
        id: invitation.attachments.last.id,
        invitation_id: invitation.id,
        invitation_attachment: {
          title: "new title",
          caption: "new caption"
        },
        format: :json
    end

    before do
      invitation.attachments.create!
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user is signed in' do
      before { stub_sign_in user }

      context 'when the user has access' do
        before do
          allow(user).to receive(:can?)
            .with(:manage_invitations, task)
            .and_return true
        end

        it 'allows updates for title and caption' do
          do_request

          attachment = invitation.attachments.last
          expect(attachment.caption).to eq('new caption')
          expect(attachment.title).to eq('new title')
        end
      end

      context 'when the user does not have access' do
        before do
          allow(user).to receive(:can?)
            .with(:manage_invitations, task)
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
