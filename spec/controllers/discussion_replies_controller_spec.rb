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

describe DiscussionRepliesController do
  let(:user) { FactoryGirl.create(:user) }
  let(:paper) { FactoryGirl.create(:paper) }
  let!(:topic_a) { FactoryGirl.create(:discussion_topic, paper: paper) }
  let!(:participation) { topic_a.discussion_participants.create!(user: user) }
  let!(:reply) { FactoryGirl.create(:discussion_reply, discussion_topic: topic_a) }

  let(:json) { res_body }

  describe 'GET show' do
    subject(:do_request) do
      xhr :get, :show, format: :json, id: reply.id
    end

    it_behaves_like "an unauthenticated json request"

    context "when the user has access" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:view, topic_a)
          .and_return true
      end

      it "includes the discussion topic reply" do
        do_request
        discussion_reply = json["discussion_reply"]
        expect(discussion_reply['id']).to eq(reply.id)
      end
    end

    context "when the user does not have access" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:view, topic_a)
          .and_return false
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe 'POST create' do
    subject(:do_request) do
      xhr :post, :create, creation_params.merge(format: 'json')
    end
    let(:body) { "You won't believe it!" }
    let(:creation_params) do
      {
        discussion_reply: {
          discussion_topic_id: topic_a.id,
          body: body,
        }
      }
    end

    it_behaves_like "an unauthenticated json request"

    context "when the user has access" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:reply, topic_a)
          .and_return true
      end

      it "creates a reply" do
        expect do
          do_request
        end.to change { DiscussionReply.count }.by(1)

        reply = json["discussion_reply"]
        expect(reply['body']).to eq(body)
        expect(reply['discussion_topic_id']).to eq(topic_a.id)
      end
    end

    context "when the user does not have access" do
      subject(:do_request) { post :create, creation_params }

      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:reply, topic_a)
          .and_return false
      end

      it { is_expected.to responds_with(403) }
    end
  end

end
