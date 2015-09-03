require 'rails_helper'

describe CommentsController do
  render_views
  let(:paper) { FactoryGirl.create(:paper, :with_tasks, creator: user) }
  let(:phase) { paper.phases.first }
  let(:user) { create(:user, tasks: []) }

  let(:journal) { paper.journal }
  let(:journal_admin) { FactoryGirl.create(:user) }
  let!(:role) { assign_journal_role(journal, journal_admin, :admin) }

  let(:task) { create(:task, phase: phase, participants: [user], title: "Task", role: "admin") }
  before { sign_in user }

  describe 'POST create' do
    subject(:do_request) do
      xhr :post, :create, format: :json,
        comment: {commenter_id: user.id,
                  body: "My comment",
                  task_id: task.id}
    end

    subject(:do_request_as_journal_admin) do
      xhr :post, :create, format: :json,
        comment: {commenter_id: journal_admin.id,
                  body: "My comment RULES",
                  task_id: task.id}
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
                      task_id: task.id}
          }.to_not change { Comment.count }
        end
      end

      context "the user is not a participant on the card" do
        let(:task) { create(:task, phase: phase, participants: [], title: "Task", role: "admin") }

        it "adds the user as a participant" do
          expect(user.tasks).to_not include(task)
          do_request
          expect(user.reload.tasks).to include(task)
        end
      end

      context "the user is a journal admin" do
        let(:task) { create(:task, phase: phase, participants: [], title: "Task", role: "admin") }

        it "does not add the journal admin as a participant" do
          expect(task.participants).to_not include(journal_admin)
          do_request_as_journal_admin
          expect(task.participants).to_not include(journal_admin)
        end

        it "increments the comment count" do
          expect { do_request_as_journal_admin }.to change { Comment.count }.by 1
        end

        it "does not adds an email to the sidekiq queue" do
          expect { do_request_as_journal_admin }.to change(Sidekiq::Extensions::DelayedMailer.jobs, :size).by(0)
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
        expect(res_body["comment"]["id"]).to eq(Comment.last.id)
      end

      it_behaves_like "an unauthenticated json request"
    end
  end
end
