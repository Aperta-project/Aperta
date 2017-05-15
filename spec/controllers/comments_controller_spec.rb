require 'rails_helper'

describe CommentsController do
  let(:paper) do
    FactoryGirl.create(
      :paper,
      creator: user,
      journal: journal
    )
  end
  let(:user) { FactoryGirl.create(:user, tasks: []) }

  let(:journal) do
    FactoryGirl.create(
      :journal,
      :with_creator_role,
      :with_collaborator_role,
      :with_task_participant_role
    )
  end
  let(:journal_admin) { FactoryGirl.create(:user) }

  let(:task) do
    FactoryGirl.create(
      :ad_hoc_task,
      paper: paper,
      participants: [user],
      title: "Task"
    )
  end

  describe "#index" do
    subject(:do_request) do
      get :index, format: 'json',
                  task_id: task.to_param
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user has access' do
      let!(:comment1) { FactoryGirl.create(:comment, task: task) }
      let!(:comment2) { FactoryGirl.create(:comment, task: task) }
      
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:view, task)
          .and_return true
      end

      it "returns the tasks comments" do
        do_request
        expect(res_body['comments'].count).to eq(2)
        expect(res_body['comments'][0]['id']).to eq(comment1.id)
      end
    end

    context "when the user does not have access" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:view, task)
          .and_return false
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe 'POST create' do
    subject(:do_request) do
      xhr :post, :create, format: :json,
                          comment: { commenter_id: user.id,
                                     body: "My comment",
                                     task_id: task.id }
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user has access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:view, task)
          .and_return true
        allow(user).to receive(:can?)
          .with(:administer, journal)
          .and_return false
      end

      context "the user tries to create a blank comment" do
        it "doesn't work" do
          expect do
            xhr :post, :create,
              format: :json,
              comment: { commenter_id: user.id,
                         body: "",
                         task_id: task.id }
          end.to_not change { Comment.count }
        end
      end

      context "the user is not a participant on the card" do
        let(:task) do
          FactoryGirl.create(
            :ad_hoc_task,
            paper: paper,
            participants: [],
            title: "Task"
          )
        end

        it "adds the user as a participant" do
          expect(user.tasks).to_not include(task)
          do_request
          expect(user.reload.tasks).to include(task)
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

      it "creates an activity" do
        activity = {
          subject: paper,
          message: "A comment was added to #{task.title} card"
        }
        expect(Activity).to receive(:create).with(hash_including(activity))
        do_request
      end

      context "the user is a journal admin" do
        subject(:do_request) do
          xhr :post, :create, format: :json,
                              comment: { commenter_id: journal_admin.id,
                                         body: "My comment RULES",
                                         task_id: task.id }
        end

        let(:task) do
          FactoryGirl.create(
            :ad_hoc_task,
            paper: paper,
            participants: [],
            title: "Task"
          )
        end

        before do
          stub_sign_in journal_admin
          allow(journal_admin).to receive(:can?)
            .with(:administer, journal)
            .and_return true
          allow(journal_admin).to receive(:can?)
            .with(:view, task)
            .and_return true
        end

        it "does not add the journal admin as a participant" do
          expect(journal_admin.tasks).to_not include(task)
          do_request
          expect(journal_admin.reload.tasks).to_not include(task)
        end

        it "increments the comment count" do
          expect { do_request }.to change { Comment.count }.by 1
        end

        it "does not add an email to the sidekiq queue" do
          expect do
            do_request
          end.not_to change(Sidekiq::Extensions::DelayedMailer.jobs, :size)
        end
      end
    end

    context "when the user does not have access" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:view, task)
          .and_return false
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe "#show" do
    let!(:comment) { FactoryGirl.create(:comment, task: task) }

    subject(:do_request) do
      get :show,         format: 'json',
                         task_id: task.to_param,
                         id: comment.to_param
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user has access' do
      before do
        stub_sign_in user
        allow(user).to \
          receive(:can?).with(:view, task).and_return true
      end

      it "returns the tasks comments" do
        do_request
        expect(res_body['comment']['id']).to eq(comment.id)
      end
    end

    context "when the user does not have access" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:view, task)
          .and_return false
      end

      it { is_expected.to responds_with(403) }
    end
  end
end
