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

describe ManuscriptAttachmentsController do
  let(:attachment) do
    FactoryGirl.build_stubbed(:manuscript_attachment, paper: paper)
  end
  let(:paper) { FactoryGirl.build_stubbed(:paper) }
  let(:user) { FactoryGirl.build_stubbed :user }

  describe 'PUT #cancel' do
    let(:attachment) do
      FactoryGirl.create(:manuscript_attachment, paper: paper)
    end
    let(:paper) { FactoryGirl.create(:paper) }
    let(:phase) { FactoryGirl.create(:phase) }
    let(:task) { FactoryGirl.create(:upload_manuscript_task, phase: phase, paper: paper) }
    let(:user) { FactoryGirl.build_stubbed :user }

    subject(:do_request) do
      put :cancel, format: 'json', id: attachment.to_param
    end

    before do
      allow(ManuscriptAttachment).to receive(:find).and_return(attachment)
      allow(attachment).to receive(:cancel_download)
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user is signed in' do
      before do
        stub_sign_in user
      end

      context 'when the user has access' do
        before do
          allow(user).to receive(:can?)
                           .with(:edit, task)
                           .and_return true
        end

        it 'cancels the upload' do
          expect(attachment).to receive(:cancel_download)
          do_request
        end

        it 'returns 204 OK' do
          do_request
          expect(response.status).to eq(204)
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

  describe 'GET #show' do
    let(:attachment) { FactoryGirl.build_stubbed(:manuscript_attachment) }

    subject(:do_request) do
      get :show, format: 'json', id: attachment.to_param
    end

    before do
      allow(ManuscriptAttachment).to receive(:find)
        .with(attachment.to_param)
        .and_return(attachment)
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user is signed in' do
      before do
        stub_sign_in user
      end

      context 'when the user has access' do
        before do
          allow(user).to receive(:can?)
            .with(:view, attachment.paper)
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
            .with(:view, attachment.paper)
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
