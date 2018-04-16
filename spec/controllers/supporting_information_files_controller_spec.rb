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

describe SupportingInformationFilesController, redis: true do
  let(:user) { create :user }
  let(:paper) { FactoryGirl.build_stubbed(:paper) }
  let(:task) { FactoryGirl.build_stubbed(:supporting_information_task, paper: paper) }
  let(:file) { FactoryGirl.build_stubbed(:supporting_information_file, paper: paper, owner: task) }
  before do
    allow(SupportingInformationFile).to receive(:find).with(file.to_param).and_return(file)
  end

  describe '#show' do
    subject(:do_request) do
      get :show, format: 'json', id: file.id
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user has access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:view, file.paper)
          .and_return true
      end

      it { is_expected.to responds_with(200) }
    end

    context 'when the user does not have access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:view, file.paper)
          .and_return false
      end

      it { is_expected.to responds_with(403) }
    end

  end

  describe 'DELETE #destroy' do
    subject(:do_request) do
      delete :destroy, format: "json", id: file.id
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user has access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, file.paper)
          .and_return true
      end

      it 'destroys the file record' do
        expect(file).to receive(:destroy)
        do_request
      end
    end

    context 'when the user does not have access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, file.paper)
          .and_return false
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe 'POST #create' do
    let(:paper) { FactoryGirl.create(:paper) }
    let(:task) { FactoryGirl.create(:supporting_information_task, paper: paper) }
    let(:url) { "http://someawesomeurl.com" }
    subject(:do_request) do
      post :create, format: "json", task_id: task.id, url: url
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user has access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, file.paper)
          .and_return true
      end

      it 'creates the supporting file' do
        expect(DownloadAttachmentWorker).to receive(:perform_async)
        expect do
          do_request
        end.to change(SupportingInformationFile, :count).by 1
      end

      it "queues up a download job" do
        expect(DownloadAttachmentWorker).to receive(:download_attachment) do |file, url_, user_|
          expect(file.paper).to eq(paper)
          expect(user_).to eq(user)
          expect(url_).to eq(url)
        end
        do_request
      end

      it "responds with 201" do
        allow(DownloadAttachmentWorker).to receive(:download_attachment)
        is_expected.to responds_with(201)
      end
    end

    context 'when the user does not have access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, paper)
          .and_return false
      end

      it { is_expected.to responds_with(403) }
    end

  end

  describe 'PUT #update' do
    subject(:do_request) do
      put :update, id: file.id,
                   supporting_information_file: { title: 'new title',
                                                  caption: 'new caption' },
                   format: :json
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user has access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, file.paper)
          .and_return true
      end

      it 'allows updates for title and caption' do
        expect(file).to receive(:update_attributes)
          .with("title" => "new title", "caption" => "new caption")

        do_request
      end
    end

    context 'when the user does not have access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, file.paper)
          .and_return false
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe 'PUT #update_attachment' do
    let(:url) { "http://someawesomeurl.com" }
    subject(:do_request) do
      put :update_attachment, id: file.id, url: url, format: :json
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user has access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, file.paper)
          .and_return true

        allow(DownloadAttachmentWorker).to receive(:download_attachment)
      end

      it "queues up a download job" do
        expect(DownloadAttachmentWorker).to receive(:download_attachment) do |file, url_, user_|
          expect(file.paper).to eq(paper)
          expect(user_).to eq(user)
          expect(url_).to eq(url)
        end
        do_request
      end

      it { is_expected.to responds_with(204) }
    end

    context 'when the user does not have access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, file.paper)
          .and_return false
      end

      it { is_expected.to responds_with(403) }
    end
  end
end
