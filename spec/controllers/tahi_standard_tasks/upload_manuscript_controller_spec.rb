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

describe TahiStandardTasks::UploadManuscriptController do
  let(:user) { FactoryGirl.create(:user) }
  let(:paper) { FactoryGirl.create(:paper) }
  let(:task) { FactoryGirl.create(:upload_manuscript_task, paper: paper) }

  describe 'PUT upload' do
    subject(:do_request) do
      put :upload, id: task.id, format: :json, manuscript_attachment: { s3_url: s3_url }
    end
    let(:s3_url) { "http://theurl.com" }

    it_behaves_like "an unauthenticated json request"

    context "when the user has access" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:edit, task)
          .and_return true
      end

      context "when the task exists but it's not an UploadManuscriptTask" do
        let(:task) { FactoryGirl.create(:ad_hoc_task, paper: paper) }

        it "responds with a 404" do
          do_request
          expect(response).to responds_with(404)
        end
      end

      context "the attachment is a manuscript attachment" do
        before do
          allow(DownloadManuscriptWorker).to receive(:download)
        end
        it "initiates manuscript download" do
          expect(DownloadManuscriptWorker).to receive(:download).with(paper, s3_url, user)
          do_request
        end

        it "responds with 201" do
          do_request
          expect(response).to responds_with(201)
        end
      end

      context "the attachment is a sourcefile attachment" do
        subject(:do_request) do
          put :upload, id: task.id, format: :json, sourcefile_attachment: { s3_url: s3_url }
        end
        before do
          allow(DownloadSourcefileWorker).to receive(:download)
        end
        it "initiates sourcefile download" do
          expect(DownloadSourcefileWorker).to receive(:download).with(paper, s3_url, user)
          do_request
        end

        it "responds with 201" do
          do_request
          expect(response).to responds_with(201)
        end
      end
    end

    context "when the user does not have access" do
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

  describe 'DESTROY destroy_manuscript' do
    subject(:do_request) do
      delete :destroy_manuscript, id: task.id, format: :json
    end

    it_behaves_like "an unauthenticated json request"

    context "when the user has access" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
                         .with(:edit, task)
                         .and_return true

        FactoryGirl.create(:manuscript_attachment, owner: paper)
      end
      it "responds with 204" do
        do_request
        expect(response).to responds_with(204)
      end

      it "deletes the manuscript" do
        expect { do_request }.to change { paper.reload.file.present? }.from(true).to(false)
      end
    end
  end

  describe 'DESTROY destroy_sourcefile' do
    subject(:do_request) do
      delete :destroy_sourcefile, id: task.id, format: :json
    end

    it_behaves_like "an unauthenticated json request"

    context "when the user has access" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
                         .with(:edit, task)
                         .and_return true

        FactoryGirl.create(:sourcefile_attachment, owner: paper)
      end
      it "responds with 204" do
        do_request
        expect(response).to responds_with(204)
      end

      it "deletes the sourcefile" do
        expect { do_request }.to change { paper.reload.sourcefile.present? }.from(true).to(false)
      end
    end
  end
end
