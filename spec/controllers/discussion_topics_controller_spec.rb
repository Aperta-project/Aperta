require 'rails_helper'

describe DiscussionTopicsController do
  render_views

  let(:user) { FactoryGirl.create(:user) }
  let(:paper) { FactoryGirl.create(:paper) }
  let!(:topic_a) { FactoryGirl.create(:discussion_topic, paper: paper) }
  let!(:topic_b) { FactoryGirl.create(:discussion_topic, paper: paper) }
  let!(:unrelated_topic) { FactoryGirl.create(:discussion_topic) }
  let!(:participation) { topic_a.discussion_participants.create!(user: user) }

  let(:json) { JSON.parse(response.body) }

  before { sign_in user }

  describe 'GET index' do

    it "includes the paper's discussion topics" do
      xhr :get, :index, format: :json, paper_id: paper.id
      topics = json["discussion_topics"]
      expect(topics.count).to eq(1)
      expect(topics[0]['id']).to eq(topic_a.id)
    end

  end

  describe 'GET show' do

    let!(:first_reply) { FactoryGirl.create(:discussion_reply, discussion_topic: topic_a) }
    let!(:last_reply) { FactoryGirl.create(:discussion_reply, discussion_topic: topic_a) }

    it "includes the discussion topic's replies" do
      xhr :get, :show, format: :json, id: topic_a.id, paper_id: paper.id

      topic = json["discussion_topic"]
      expect(topic['id']).to eq(topic_a.id)

      replies = json['discussion_replies']
      expect(replies[0]['id']).to eq(first_reply.id)
      expect(replies[1]['id']).to eq(last_reply.id)
    end

  end

  describe 'POST create' do
    let(:title) { "Shocking new topic!" }
    let(:body) { "You won't believe it!" }
    let(:creation_params) do
      {
        paper_id: paper.id,
        discussion_topic: { title: title },
        discussion_reply: { body: body },
      }
    end

    it "includes the discussion topic's replies" do
      expect {
        xhr :post, :create, format: :json, **creation_params
      }.to change { DiscussionTopic.count }.by(1)

      topic = json["discussion_topic"]
      expect(topic['title']).to eq(title)
      expect(topic['paper_id']).to eq(paper.id)

      reply = json['discussion_replies'].first
      expect(reply['body']).to eq(body)
      expect(reply['replier_id']).to eq(user.id)
    end

  end

  describe 'PATCH update' do
    let(:new_title) { "EDIT: better topic title!" }
    let(:update_params) do
      {
        paper_id: paper.id,
        id: topic_a.id,
        discussion_topic: { title: new_title },
      }
    end

    it "updates the topic" do
      xhr :patch, :update, format: :json, **update_params
      expect(topic_a.reload.title).to eq(new_title)
    end

  end

  describe 'DELETE destroy' do

    it "destroys a topic" do
      expect {
        xhr :delete, :destroy, format: :json, id: topic_a.id, paper_id: paper.id
      }.to change { DiscussionTopic.count }.by(-1)
    end

  end


end
