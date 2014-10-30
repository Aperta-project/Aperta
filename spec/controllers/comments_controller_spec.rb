require 'spec_helper'

describe CommentsController do
  render_views
  let(:paper) { FactoryGirl.create(:paper, :with_tasks, user: user) }
  let(:phase) { paper.phases.first }
  let(:user) { create(:user) }

  let(:message_task) { create(:message_task, phase: phase, participants: [user], title: "Message Task", role: "admin") }
  before { sign_in user }

  describe 'POST create' do
    subject(:do_request) do
      xhr :post, :create, format: :json,
        comment: {commenter_id: user.id,
                  body: "My comment",
                  task_id: message_task.id}
    end

    context "the user isn't authorized" do
      authorize_policy(CommentsPolicy, false)

      it "renders 403" do
        do_request
        expect(response.status).to eq(403)
      end
    end

    context "the user is authorized" do
      authorize_policy(CommentsPolicy, true)

      context "the user tries to create a blank comment" do
        it "doesn't work" do
          expect {
            xhr :post, :create,
            format: :json,
            comment: {commenter_id: user.id,
                      body: "",
                      task_id: message_task.id}
          }.to_not change { Comment.count }
        end
      end

      it "creates a new comment" do
        do_request
        expect(Comment.last.body).to eq('My comment')
        expect(Comment.last.commenter_id).to eq(user.id)
      end

      it "returns the new comment as json" do
        do_request
        expect(response.status).to eq(201)
        json = JSON.parse(response.body)
        expect(json["comment"]["id"]).to eq(Comment.last.id)
      end
      it_behaves_like "an unauthenticated json request"
    end
  end
end
