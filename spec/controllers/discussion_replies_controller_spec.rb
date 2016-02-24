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

  describe 'GET show' do
    context "when the user has access" do
      before do
        allow_any_instance_of(User).to receive(:can?)
          .with(:view, topic_a)
          .and_return true
      end

      it "includes the discussion topic reply" do
        xhr :get, :show, format: :json, id: reply.id

        discussion_reply = json["discussion_reply"]
        expect(discussion_reply['id']).to eq(reply.id)
      end
    end

    context "when the user does not have access" do
      before do
        allow_any_instance_of(User).to receive(:can?)
          .with(:view, topic_a)
          .and_return false
      end

      it { responds_with(403) }
    end
  end

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

    context "when the user has access" do
      before do
        allow_any_instance_of(User).to receive(:can?)
          .with(:reply, topic_a)
          .and_return true
      end

      it "creates a reply" do
        expect do
          xhr :post, :create, format: :json, **creation_params
        end.to change { DiscussionReply.count }.by(1)

        reply = json["discussion_reply"]
        expect(reply['body']).to eq(body)
        expect(reply['discussion_topic_id']).to eq(topic_a.id)
      end
    end

    context "when the user does not have access" do
      before do
        allow_any_instance_of(User).to receive(:can?)
          .with(:reply, topic_a)
          .and_return false
      end

      let!(:do_request) { post :create, creation_params }

      it { responds_with(403) }
    end
  end

end
