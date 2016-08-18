require 'rails_helper'

describe TasksController, redis: true do
  let(:user) { FactoryGirl.create :user }
  let(:journal) do
    FactoryGirl.create(
      :journal,
      :with_creator_role,
      :with_task_participant_role
    )
  end
  let!(:paper) do
    FactoryGirl.create(
      :paper,
      :with_tasks,
      creator: user,
      journal: journal
    )
  end

  describe "#index" do
    subject(:do_request) do
      get :index, {
             format: 'json',
             paper_id: paper.to_param,
           }
    end
    let(:tasks){ [FactoryGirl.build_stubbed(:task)] }

    it_behaves_like "an unauthenticated json request"

    context "when the user has access" do
      before do
        stub_sign_in(user)

        allow(user).to receive(:can?)
          .with(:view, paper)
          .and_return true

        allow(user).to receive(:filter_authorized).and_return instance_double(
          'Authorizations::Query::Result',
          objects: tasks
        )
      end

      it "returns only the paper's tasks the user has access to" do
        expect(user).to receive(:filter_authorized).with(
          :view,
          paper.tasks.includes(:paper),
          participations_only: false
        ).and_return instance_double(
          'Authorizations::Query::Result',
          objects: tasks
        )
        do_request
        expect(res_body['tasks'].count).to eq(1)
      end
    end

    context "when the user does not have access" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:view, paper)
          .and_return false
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe "POST 'create'" do
    subject(:do_request) do
      post :create, {
        format: 'json',
        task: {
          type: 'TahiStandardTasks::AuthorsTask',
          paper_id: paper.to_param,
          phase_id: paper.phases.last.id,
          title: 'Verify Signatures'
        }
      }
    end

    it_behaves_like "an unauthenticated json request"

    context "when the user has access" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:manage_workflow, paper)
          .and_return true
      end

      it "creates a task" do
        expect { do_request }.to change(Task, :count).by 1
      end
    end

    context "when the user does not have access" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:manage_workflow, paper)
          .and_return false
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe "PATCH 'update'" do
    let(:task) do
      FactoryGirl.create(:task, paper: paper, phase: paper.phases.first)
    end

    subject(:do_request) do
      xhr(
        :patch,
        :update, {
          format: 'json',
          paper_id: paper.to_param,
          id: task.to_param, task: { completed: '1' } } )
    end

    it_behaves_like "an unauthenticated json request"

    context "when the user has access" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, task)
          .and_return true
      end

      it "updates the task" do
        do_request
        expect(task.reload).to be_completed
      end

      it "renders the task id and completed status as JSON" do
        do_request
        expect(response.status).to eq(200)
      end

      context "when the task is assigned to the user" do
        let(:new_assignee) { FactoryGirl.create(:user) }

        before do
          user.update! site_admin: false
          task.add_participant(user)
        end

        it "updates the task" do
          do_request
          expect(task.reload).to be_completed
        end
      end

      context "when the user cannot edit the task" do
        subject(:do_unauthorized_request) do
          xhr :patch, :update, {
            format: 'json',
            paper_id: paper.to_param,
            id: task.to_param,
            task: { completed: '1' }
          }
        end

        before do
          allow(user).to receive(:can?)
            .with(:edit, task)
            .and_return false
        end

        describe "a submission card" do
          it "returns a 403" do
            do_unauthorized_request
            expect(response.status).to eq 403
          end

          it "does not update the task" do
            do_unauthorized_request
            expect(task.reload).not_to be_completed
          end
        end

        describe "the user can edit the task" do
          before do
            allow_any_instance_of(User).to receive(:can?)
              .with(:edit, task)
              .and_return true
          end

          it "returns a 200" do
            do_request
            expect(response.status).to eq 200
          end

          it "does update the task" do
            do_request
            expect(task.reload).to be_completed
          end

          it "does not raises an error" do
            do_request
            expect(response.body).not_to include "This paper cannot be edited at this time."
          end
        end
      end
    end
  end

  describe "GET 'show'" do
    let(:task) { FactoryGirl.create(:task) }
    subject(:do_request) { get :show, { id: task.id, format: :json } }
    let(:format) { :json }

    context "when the user has access" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:view, task)
          .and_return true
      end

      context "json requests" do
        it "calls the Task subclass's appropriate serializer when rendering JSON" do
          do_request
          serializer = task.active_model_serializer.new(task, scope: user)
          expect(res_body.keys).to match_array(serializer.as_json.stringify_keys.keys)
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

  describe "PUT 'send_message'" do
    let(:task) { FactoryGirl.create(:task) }

    subject(:do_request) do
      put :send_message, {
        id: task.id, format: "json",
        task: {
          subject: "Hello",
          body: "Greetings from Vulcan!",
          recipients: [user.id]
        }
      }
    end

    context "when the user has access" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, task)
          .and_return true
      end

      it "adds an email to the SideKiq queue" do
        expect { do_request }.to change(Sidekiq::Extensions::DelayedMailer.jobs, :size).by(1)
      end

      it "adds multiple emails to the SideKiq queue" do
        user2 = FactoryGirl.create(:user)
        before_queue_size = Sidekiq::Extensions::DelayedMailer.jobs.size

        expect do
          put :send_message,
              id: task.id, format: "json",
              task: {
                subject: "Hello",
                body: "Greetings from Vulcan!",
                recipients: [user.id, user2.id]
              }
        end.to change(Sidekiq::Extensions::DelayedMailer.jobs, :size).by(2)
      end
    end

    context "when the user does not have access" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, task)
          .and_return false
      end

      it { is_expected.to responds_with(403) }
    end
  end
end
