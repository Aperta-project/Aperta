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

describe DecisionAttachmentsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:paper) { FactoryGirl.create(:paper) }
  let!(:decision) { FactoryGirl.create(:decision, paper: paper) }

  describe '#index' do
    let!(:decision_attachment) { FactoryGirl.create(:decision_attachment, owner: decision) }

    subject(:do_request) do
      get :index, format: :json, decision_id: decision.id
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user is authorized to :view the decision attachment' do
      before do
        stub_sign_in user
      end

      it 'it includes the decision attachment on the json' do
        allow(user).to receive(:can?)
          .with(:view, decision)
          .and_return true

        do_request

        data = res_body.with_indifferent_access
        expect(data).to have_key(:attachments)
        expect(res_body['attachments'][0]['id']).to eq(decision_attachment.id)
      end
    end
  end

  describe "#update_attachment" do
    let!(:decision_attachment) { FactoryGirl.create(:decision_attachment, owner: decision) }
    let!(:task) do
      FactoryGirl.create(
        :revise_task,
        :with_loaded_card,
        completed: true,
        paper: paper
      )
    end
    let(:url) { Faker::Internet.url('example.com') }

    subject(:do_request) do
      put :update_attachment,
          format: :json,
          decision_id: decision.id,
          id: decision_attachment.id,
          url: url
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user is authorized to :view the decision attachment' do
      before do
        stub_sign_in user
      end

      it 'it updates' do
        allow(user).to receive(:can?)
          .with(:edit, task)
          .and_return true

        expect(DownloadAttachmentWorker).to receive(:perform_async)
          .with(decision_attachment.id, url, user.id)

        do_request

        data = res_body.with_indifferent_access
        expect(data).to have_key("attachment")
        expect(res_body['attachment']['id']).to eq(decision_attachment.id)
      end
    end
  end
end
