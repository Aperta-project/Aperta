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

describe DiscussionParticipantsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:another_user) { FactoryGirl.create(:user) }
  let(:paper) { FactoryGirl.create(:paper, journal: journal) }
  let!(:topic_a) { FactoryGirl.create(:discussion_topic, paper: paper) }
  let!(:participation) { topic_a.discussion_participants.create!(user: user) }

  let(:journal) do
    FactoryGirl.create(
      :journal,
      :with_creator_role,
      :with_discussion_participant_role
    )
  end

  let(:json) { res_body }

  describe 'POST create' do
    include ActiveJob::TestHelper

    subject(:do_request) do
      xhr :post, :create, creation_params.merge(format: :json)
    end

    before { ActionMailer::Base.deliveries.clear }
    after  { clear_enqueued_jobs }

    let(:creation_params) do
      {
        discussion_participant: {
          discussion_topic_id: topic_a.id,
          user_id: another_user.id,
        }
      }
    end

    it_behaves_like "an unauthenticated json request"

    context "when the user has access" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:manage_participant, topic_a)
          .and_return true
      end

      it "adds a user to a discussion" do
        expect do
          do_request
        end.to change { DiscussionParticipant.count }.by(1)

        participant = json["discussion_participant"]
        expect(participant['discussion_topic_id']).to eq(topic_a.id)
        expect(participant['user_id']).to eq(another_user.id)
      end
    end

    context "when the user does not have access" do
      subject(:do_request) { post :create, creation_params }
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:manage_participant, topic_a)
          .and_return false
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe 'DELETE destroy' do
    subject(:do_request) do
      xhr :delete, :destroy, format: :json, id: participation.to_param
    end

    it_behaves_like "an unauthenticated json request"

    context "when the user has access" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:manage_participant, topic_a)
          .and_return true
      end

      it "destroys a participant" do
        expect do
          do_request
        end.to change { DiscussionParticipant.count }.by(-1)
      end
    end

    context "when the user does not have access" do
      subject(:do_request) { delete :destroy, id: participation.to_param }

      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:manage_participant, topic_a)
          .and_return false
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe 'GET show' do
    subject(:do_request) do
      xhr :get, :show, format: :json, id: participation.to_param
    end

    it_behaves_like "an unauthenticated json request"

    context "when the user has access" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:view, topic_a)
          .and_return true
      end

      it "responds with a participation" do
        do_request
        expect(response).to be_success
        participant = json["discussion_participant"]
        expect(participant["id"]).to eq participation.id
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
end
