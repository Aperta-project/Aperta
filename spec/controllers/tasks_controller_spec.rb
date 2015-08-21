require 'rails_helper'

describe TasksController, redis: true do
  let(:user) { create :user, :site_admin }

  let!(:paper) do
    FactoryGirl.create(:paper, :with_tasks, creator: user)
  end

  before do
    sign_in user
  end

  describe "POST 'create'" do
    subject(:do_request) do
      post :create, {
        format: 'json',
        paper_id: paper.to_param,
        task: {
          type: 'Task',
          phase_id: paper.phases.last.id,
          title: 'Verify Signatures'
        }
      }
    end

    it_behaves_like "an unauthenticated json request"

    it "creates a task" do
      expect { do_request }.to change(Task, :count).by 1
    end
  end

  describe "PATCH 'update'" do
    let(:task) { FactoryGirl.create(:task, phase: paper.phases.first) }
    let(:cover_letter_task) { FactoryGirl.create(:cover_letter_task, phase: paper.phases.first) }

    subject(:do_request) do
      xhr :patch, :update, { format: 'json', paper_id: paper.to_param, id: task.to_param, task: { completed: '1' } }
    end

    subject(:do_unathorized_request) do
      xhr :patch, :update, { format: 'json', paper_id: paper.to_param, id: cover_letter_task.to_param, task: { completed: '1' } }
    end

    it_behaves_like "an unauthenticated json request"

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

    context "when the user is not an admin or the assignee" do
      before { user.update! site_admin: false }

      it "returns a 403" do
        do_request
        expect(response.status).to eq 403
      end

      it "does not update the task" do
        do_request
        expect(task.reload).not_to be_completed
      end
    end

    context "when the task is a ReviewerReportTask" do
      let!(:reviewer_task) {
        TahiStandardTasks::ReviewerReportTask.create!(title: "Reviewer Report",
        role: "reviewer",
        phase: paper.phases.first,
        completed: false)
      }

      it "calls the send_emails method" do
        expect_any_instance_of(TahiStandardTasks::ReviewerReportTask).to receive(:send_emails)
        xhr :patch, :update, { format: 'json', paper_id: paper.to_param, id: reviewer_task.to_param, task: { completed: true } }
      end
    end

    context "when the paper is not editable" do
      before { paper.update! editable: false }

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

      describe "a non-submission card" do
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

  describe "GET 'show'" do
    let(:task) { FactoryGirl.create(:task) }
    subject(:do_request) { get :show, { id: task.id, format: format } }

    context "html requests" do
      let(:format) { nil }
      it_behaves_like "when the user is not signed in"
    end

    context "json requests" do
      let(:format) { :json }

      it "calls the Task subclass's appropriate serializer when rendering JSON" do
        do_request
        serializer = task.active_model_serializer.new(task, user: user)
        expect(res_body.keys).to match_array(serializer.as_json.stringify_keys.keys)
      end
    end
  end

  describe "PUT 'send_message'" do
    let(:task) { FactoryGirl.create(:task) }

    subject(:do_request) { put :send_message, { id: task.id, format: "json", task: {subject: "Hello", body: "Greetings from Vulcan!", recepients: [user.id]} } }

    it "adds an email to the SideKiq queue" do
      expect { do_request }.to change(Sidekiq::Extensions::DelayedMailer.jobs, :size).by(1)
    end
  end
end
