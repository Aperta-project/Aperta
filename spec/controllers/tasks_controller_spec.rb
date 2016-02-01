require 'rails_helper'

describe TasksController, redis: true do
  let(:user) { create :user }

  let!(:paper) do
    FactoryGirl.create(:paper, :with_tasks, creator: user)
  end

  before do
    assign_author_role(paper, user)
    sign_in user
  end

  describe "#index" do
    subject(:do_request) do
      get :index, {
             format: 'json',
             paper_id: paper.to_param,
           }
    end

    it_behaves_like "an unauthenticated json request"

    context "when the user has access" do
      before do
        allow_any_instance_of(User).to receive(:can?)
          .with(:view, paper)
          .and_return true
      end

      it "returns the paper's tasks" do
        do_request
        expect(res_body['tasks'].count).to eq(paper.tasks.count)
      end
    end

    context "when the user does not have access" do
      before do
        allow_any_instance_of(User).to receive(:can?)
          .with(:view, paper)
          .and_return false
      end

      it { responds_with(403) }
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
        allow_any_instance_of(User).to receive(:can?)
          .with(:manage_workflow, paper)
          .and_return true
      end

      it "creates a task" do
        expect { do_request }.to change(Task, :count).by 1
      end

      it "creates a task, includes the paper creator if is submission task " do
        do_request
        expect(Task.last.participants).to include(paper.creator)
      end
    end

    context "when the user does not have access" do
      before do
        allow_any_instance_of(User).to receive(:can?)
          .with(:manage_workflow, paper)
          .and_return false
      end

      it { responds_with(403) }
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
        allow_any_instance_of(User).to receive(:can?)
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
          task.participants << user
        end

        it "updates the task" do
          do_request
          expect(task.reload).to be_completed
        end
      end

      context "when the task is a ReviewerReportTask" do
        let!(:task) do
          TahiStandardTasks::ReviewerReportTask.create!(
            title: "Reviewer Report",
            old_role: "reviewer",
            phase: paper.phases.first,
            paper: paper,
            completed: false
          )
        end

        it "calls the send_emails method" do
          expect_any_instance_of(TahiStandardTasks::ReviewerReportTask).to receive(:send_emails)
          xhr :patch, :update, { format: 'json', paper_id: paper.to_param, id: task.to_param, task: { completed: true } }
        end
      end

      context "when the paper is not editable" do
        subject(:do_unathorized_request) do
          xhr :patch, :update, {
            format: 'json',
            paper_id: paper.to_param,
            id: task.to_param,
            task: { completed: '1' }
          }
        end

        before do
          allow_any_instance_of(Task).to receive(:allow_update?)
            .and_return false
        end

        describe "a submission card" do
          it "returns a 422" do
            do_unathorized_request
            expect(response.status).to eq 422
          end

          it "does not update the task" do
            do_unathorized_request
            expect(task.reload).not_to be_completed
          end

          it "raises an error" do
            do_unathorized_request
            expect(response.body).to include "This paper cannot be edited at this time."
          end
        end

        describe "the paper is editable" do
          before do
            allow_any_instance_of(Task).to receive(:allow_update?)
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

    context "when the user does not have access" do
      before do
        allow_any_instance_of(User).to receive(:can?)
          .with(:edit, task)
          .and_return false
      end

      it { responds_with(403) }
    end
  end

  describe "GET 'show'" do
    let(:task) { FactoryGirl.create(:task) }
    subject(:do_request) { get :show, { id: task.id, format: format } }
    let(:format) { :json }

    context "when the user has access" do
      before do
        allow_any_instance_of(User).to receive(:can?)
          .with(:view, task)
          .and_return true
      end

      context "html requests" do
        let(:format) { nil }
        it_behaves_like "when the user is not signed in"
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
        allow_any_instance_of(User).to receive(:can?)
          .with(:view, task)
          .and_return false
      end

      it { responds_with(403) }
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
          recepients: [user.id]
        }
      }
    end

    context "when the user has access" do
      before do
        allow_any_instance_of(User).to receive(:can?)
          .with(:edit, task)
          .and_return true
      end

      it "adds an email to the SideKiq queue" do
        expect { do_request }.to change(Sidekiq::Extensions::DelayedMailer.jobs, :size).by(1)
      end
    end

    context "when the user does not have access" do
      before do
        allow_any_instance_of(User).to receive(:can?)
          .with(:edit, task)
          .and_return false
      end

      it { responds_with(403) }
    end
  end
end
