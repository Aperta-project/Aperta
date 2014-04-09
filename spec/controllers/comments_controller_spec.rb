require 'spec_helper'

describe CommentsController do
  render_views
  let(:phase) { task_manager.phases.first }
  let(:paper) { FactoryGirl.create(:paper, user: paper_user) }
  let(:task_manager) { paper.task_manager }

  let(:user) { FactoryGirl.create(:user) }
  let(:other_user) { FactoryGirl.create(:user) }

  let(:message_task) { FactoryGirl.create(:message_task, phase: phase, participants: [paper_user]) }
  before { sign_in user }

  describe 'POST create' do
    subject(:do_request) do
      post :create, format: :json,
        comment: {commenter_id: user.id,
                  body: "My comment",
                  message_task_id: message_task.id}
    end

    context "the user can't see the task's paper" do
      let(:paper_user) { other_user }
      it "renders 404" do
        do_request
        expect(response.status).to eq(404)
      end
    end

    context "the user can see the task's paper" do
      let(:paper_user) { user }
      it "creates a new comment" do
        do_request
        expect(Comment.last.body).to eq('My comment')
        expect(Comment.last.commenter_id).to eq(user.id)
      end

      it "returns the new comment as json" do
        do_request
        json = JSON.parse(response.body)
        expect(json["comment"]["id"]).to eq(Comment.last.id)
      end
      it_behaves_like "an unauthenticated json request"
    end
  end
end
