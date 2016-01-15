require 'rails_helper'

describe DiscussionRepliesController do
  let(:user) { FactoryGirl.create(:user) }
  let(:paper) { FactoryGirl.create(:paper) }
  let!(:paper_role) { FactoryGirl.create(:paper_role, :editor, paper: paper, user: user) }
  let!(:topic_a) { FactoryGirl.create(:discussion_topic, paper: paper) }
  let!(:participation) { topic_a.discussion_participants.create!(user: user) }
  let!(:reply) { FactoryGirl.create(:discussion_reply, discussion_topic: topic_a) }

  let(:json) { res_body }

  before { sign_in user }

  describe 'POST create' do
    render_views

    let(:body) { "You won't believe it!" }
    let(:creation_params) do
      {
        discussion_reply: {
          discussion_topic_id: topic_a.id,
          body: body,
        }
      }
    end

    it "creates a reply" do
      expect {
        xhr :post, :create, format: :json, **creation_params
      }.to change { DiscussionReply.count }.by(1)

      reply = json["discussion_reply"]
      expect(reply['body']).to eq(body)
      expect(reply['discussion_topic_id']).to eq(topic_a.id)
    end
  end

  describe 'DELETE destroy' do

    it "destroys a reply" do
      expect {
        xhr :delete, :destroy, format: :json, id: reply.id
      }.to change { DiscussionReply.count }.by(-1)
    end

  end


end
