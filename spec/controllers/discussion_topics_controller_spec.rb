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

describe DiscussionTopicsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:paper) { FactoryGirl.create(:paper) }
  let!(:topic_a) { FactoryGirl.create(:discussion_topic, paper: paper) }
  let!(:topic_b) { FactoryGirl.create(:discussion_topic, paper: paper) }
  let!(:unrelated_topic) { FactoryGirl.create(:discussion_topic) }
  let!(:participation) { topic_a.discussion_participants.create!(user: user) }

  let(:json) { res_body }

  describe 'GET index' do
    subject(:do_request) do
      xhr :get, :index, format: :json, paper_id: paper.id
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user is authenticated' do
      before do
        stub_sign_in user
        allow(user).to receive(:filter_authorized)
          .with(:view, paper.discussion_topics)
          .and_return instance_double('Authorizations::Query::Result', objects: [topic_a])
        allow(user).to receive(:can?).with(:view, topic_a).and_return(true)
      end

      it "includes the paper's discussion topics" do
        do_request
        topics = json["discussion_topics"]
        expect(topics.count).to eq(1)
        expect(topics[0]['id']).to eq(topic_a.id)
      end
    end
  end

  describe 'GET show' do
    subject(:do_request) do
      xhr :get, :show, format: :json, id: topic_a.id
    end

    let!(:first_reply) { FactoryGirl.create(:discussion_reply, discussion_topic: topic_a) }
    let!(:last_reply) { FactoryGirl.create(:discussion_reply, discussion_topic: topic_a) }

    it_behaves_like 'an unauthenticated json request'

    context "when the user has access" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:view, topic_a)
          .and_return true
      end

      it "includes the discussion topic's replies" do
        do_request
        topic = json["discussion_topic"]
        expect(topic['id']).to eq(topic_a.id)

        replies = json['discussion_replies']
        expect(replies[0]['id']).to eq(first_reply.id)
        expect(replies[1]['id']).to eq(last_reply.id)
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
      xhr :post, :create, creation_params.merge(format: :json)
    end

    let(:title) { "Shocking new topic!" }
    let(:body) { "You won't believe it!" }
    let(:creation_params) do
      {
        discussion_topic: {
          paper_id: paper.id,
          title: title,
          initial_discussion_participant_ids: [user.to_param]
        }
      }
    end

    it_behaves_like 'an unauthenticated json request'

    context "when the user has access" do
      let(:role) { FactoryGirl.create(:role, name: 'DISCUSSION_PARTICIPANT_ROLE') }

      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:start_discussion, paper)
          .and_return true
        allow_any_instance_of(Journal).to receive(:discussion_participant_role).and_return(role)
        allow(user).to receive(:can?).with(:view, an_instance_of(DiscussionTopic)).and_return(true)
      end

      it "creates a topic" do
        expect do
          do_request
        end.to change { DiscussionTopic.count }.by(1)

        topic = json["discussion_topic"]
        expect(topic['title']).to eq(title)
        expect(topic['paper_id']).to eq(paper.id)
      end

      describe "initial discussion participant assignment" do
        let!(:users_to_assign) { create_list :user, 3 }
        let(:creation_params) do
          {
            discussion_topic: {
              paper_id: paper.id,
              title: title,
              initial_discussion_participant_ids: users_to_assign.map(&:id)
            }
          }
        end

        it "assigns all users in initial_discussion_participant_ids as participants" do
          expect do
            do_request
          end.to change { DiscussionParticipant.count }.by(users_to_assign.length)
          discussion_topic = DiscussionTopic.last
          expect(discussion_topic.participants.all).to match users_to_assign
        end
      end
    end

    context "when the user does not have access" do
      subject(:do_request) { post :create, creation_params }

      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:start_discussion, paper)
          .and_return false
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe 'PATCH update' do
    subject(:do_request) do
      xhr :patch, :update, update_params.merge(format: :json)
    end

    let(:new_title) { "EDIT: better topic title!" }
    let(:update_params) do
      {
        id: topic_a.id,
        discussion_topic: {
          title: new_title
        }
      }
    end

    context "when the user has access" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, topic_a)
          .and_return true
      end

      it "updates the topic" do
        do_request
        expect(topic_a.reload.title).to eq(new_title)
      end
    end

    context "when the user does not have access" do
      subject(:do_request) { patch :update, update_params }
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, topic_a)
          .and_return false
      end

      it { is_expected.to responds_with(403) }
    end
  end

  shared_examples_for 'a participant search endpoint' do
    context 'when the user is authorized' do
      before do
        stub_sign_in user
      end

      it 'returns any user who matches the query' do
        do_request
        expect(res_body['users'].count).to eq(1)
        expect(res_body['users'][0]['email']).to eq('foo@example.com')
      end
    end
  end

  describe 'requests using fuzzy search' do
    before do
      # Stub this out because fuzzy_search can return strange results when using
      # random faked user data.
      allow(User).to receive(:fuzzy_search)
        .with('Kangaroo')
        .and_return [FactoryGirl.build_stubbed(:user, email: 'foo@example.com')]
    end


    describe 'GET users' do
      subject(:do_request) do
        xhr :get, :users, format: :json, id: topic_a.id, query: 'Kangaroo'
      end

      before do
        allow(user).to receive(:can?)
                         .with(:manage_participant, topic_a)
                         .and_return true
      end

      it_behaves_like 'an unauthenticated json request'
      it_behaves_like 'a participant search endpoint'
    end

    describe 'GET new_discussion_users' do
      subject(:do_request) do
        xhr :get, :new_discussion_users, format: :json, paper_id: paper.to_param, query: 'Kangaroo'
      end

      before do
        allow(user).to receive(:can?)
                         .with(:start_discussion, paper)
                         .and_return true
      end

      it_behaves_like 'an unauthenticated json request'
      it_behaves_like 'a participant search endpoint'
    end
  end
end
