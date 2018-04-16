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

describe QuestionAttachmentsController do
  let(:user) { FactoryGirl.build_stubbed :user }
  let!(:question_attachment) do
    FactoryGirl.create(:question_attachment, owner: answer)
  end
  let!(:answer) { FactoryGirl.create(:answer, owner: task, paper: task.paper) }
  let(:task) { FactoryGirl.create(:ad_hoc_task) }

  describe "#show" do
    subject(:do_request) do
      get :show, format: :json, id: question_attachment.to_param
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user has access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:view, question_attachment.owner.task)
          .and_return(true)
      end

      it "succeeds" do
        do_request
        expect(response.status).to be(200)
      end

      it 'returns the question attachment' do
        do_request
        expect(res_body['question_attachment']['id']).to be(question_attachment.id)
      end
    end

    context 'when the user does not have access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:view, question_attachment.owner.task)
          .and_return(false)
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe '#destroy' do
    subject(:do_request) do
      put :destroy, format: :json, id: question_attachment.id
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user has access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, question_attachment.owner.task)
          .and_return(true)
      end

      it 'destroys the question' do
        expect do
          do_request
        end.to change { QuestionAttachment.count }.by(-1)
      end
    end

    context 'when the user does not have access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, question_attachment.owner.task)
          .and_return(false)
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe '#create' do
    subject(:do_request) do
      post :create, format: :json, question_attachment: {
        nested_question_answer_id: answer.id,
        caption: 'This is a great caption!',
        src: 'http://some.cat.image.gif'
      }
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user has access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, answer.task)
          .and_return(true)
      end

      it 'creates a new question attachment' do
        expect { do_request }.to change { answer.attachments.count }.by(1)
        attachment = answer.attachments.last
        expect(attachment.caption).to eq('This is a great caption!')
      end

      it 'sets the paper on the question attachment' do
        do_request
        attachment = answer.attachments.last
        expect(answer.paper).to_not be(nil)
        expect(attachment.paper).to eq(answer.paper)
      end

      it 'processes the attachment in the background' do
        do_request
        question_attachment = answer.attachments.last
        expect(DownloadAttachmentWorker).to have_queued_job(
          question_attachment.id,
          'http://some.cat.image.gif',
          user.id
        )
      end

      it 'returns json only including question_attachment id' do
        do_request
        question_attachment = answer.attachments.last
        expect(JSON.parse(response.body)).to eq({
          'question-attachment': { id: question_attachment.id }
        }.as_json)
      end
    end

    context 'when the user does not have access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, answer.task)
          .and_return(false)
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe '#update' do
    subject(:do_request) do
      put :update, format: :json, question_attachment: {
        caption: 'This is a great caption!', src: 'http://some.cat.image.gif'
      }, id: question_attachment.id
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user has access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, answer.task)
          .and_return(true)
      end

      it 'updates a question attachment' do
        expect { do_request }.to_not change { answer.attachments.count }
        question_attachment.reload
        expect(question_attachment.caption).to eq('This is a great caption!')
      end

      it 'processes the attachment in the background' do
        do_request
        expect(DownloadAttachmentWorker).to have_queued_job(
          question_attachment.id,
          'http://some.cat.image.gif',
          user.id
        )
      end

      it 'returns json only including question_attachment id' do
        do_request
        expect(JSON.parse(response.body)).to eq({
          'question-attachment': { id: question_attachment.id }
        }.as_json)
      end
    end

    context 'when the user does not have access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, answer.task)
          .and_return(false)
      end

      it { is_expected.to responds_with(403) }
    end
  end
end
