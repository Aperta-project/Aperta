require 'spec_helper'

class FakeTask < Task
  PERMITTED_ATTRIBUTES = [{ some_attribute: [some_value: []] }]
end

describe TasksController do
  let(:permitted_params) { [:assignee_id, :completed, :title, :body, :phase_id] }

  let :user do
    User.create! username: 'albert',
      first_name: 'Albert',
      last_name: 'Einstein',
      email: 'einstein@example.org',
      password: 'password',
      password_confirmation: 'password',
      affiliation: 'Universität Zürich',
      admin: true
  end

  before { sign_in user }

  describe "GET 'index'" do
    let(:paper) { Paper.create! short_title: "abcd", journal: Journal.create! }

    subject(:do_request) { get 'index', id: paper.to_param }

    it_behaves_like "when the user is not signed in"
    it_behaves_like "when the user is not an admin"

    it "renders index template" do
      do_request
      expect(response).to render_template(:index)
    end
  end

  describe "POST 'create'" do
    let!(:paper) { Paper.create! short_title: 'some-paper', journal: Journal.create! }

    subject(:do_request) do
      post :create, { paper_id: paper.to_param, task: { assignee_id: '1',
                                                        phase_id: paper.task_manager.phases.last.id,
                                                        title: 'Verify Signatures',
                                                        body: 'Seriously, do it!' } }
    end

    it_behaves_like "when the user is not signed in"

    it_behaves_like "a controller enforcing strong parameters" do
      let(:params_id) { task.to_param }
      let(:paper_id) { paper.to_param }
      let(:model_identifier) { :task }
      let(:expected_params) { permitted_params }
    end

    it "creates a task" do
      expect { do_request }.to change(Task, :count).by 1
    end
  end

  describe "PATCH 'update'" do
    let(:paper) { Paper.create! short_title: 'paper-yet-to-be-updated', journal: Journal.create! }
    let(:task) { Task.create! title: "sample task", role: "sample role", phase: paper.task_manager.phases.first }

    subject(:do_request) do
      patch :update, { paper_id: paper.to_param, id: task.to_param, task: { completed: '1' } }
    end

    it_behaves_like "when the user is not signed in"

    it_behaves_like "a controller enforcing strong parameters" do
      let(:params_id) { task.to_param }
      let(:paper_id) { paper.to_param }
      let(:model_identifier) { :task }
      let(:expected_params) { permitted_params }
    end

    describe "subclasses of task" do
      let(:task) { FakeTask.create! title: "sample task", role: "sample role", phase: paper.task_manager.phases.first }
      let(:permitted_params) { [:assignee_id, :completed, :title, :body, :phase_id, some_attribute: [some_value: []]] }

      it_behaves_like "a controller enforcing strong parameters" do
        let(:params_id) { task.to_param }
        let(:paper_id) { paper.to_param }
        let(:model_identifier) { :task }
        let(:expected_params) { permitted_params }
      end
    end

    context "when the user is an admin" do
      it "updates the task" do
        do_request
        expect(task.reload).to be_completed
      end

      it "renders the task id and completed status as JSON" do
        do_request
        expect(JSON.parse(response.body)).to eq({ id: task.id, completed: true }.with_indifferent_access)
      end
    end

    context "when the task is assigned to the user" do
      before do
        user.update! admin: false
        task.update! assignee: user
      end

      it "updates the task" do
        do_request
        expect(task.reload).to be_completed
      end
    end

    context "when the user is not an admin or the assignee" do
      before { user.update! admin: false }

      it "returns a 403" do
        do_request
        expect(response.status).to eq 403
      end

      it "does not update the task" do
        do_request
        expect(task.reload).not_to be_completed
      end
    end
  end

  describe "GET 'show'" do
    let!(:paper) { Paper.create! short_title: "abcd", journal: Journal.create! }
    let(:task) { Task.where(title: "Assign Admin").first }

    let(:format) { nil }

    it_behaves_like "when the user is not signed in"

    subject(:do_request) { get :show, { id: task.id, paper_id: paper.id, format: format } }

    it "assigns the task from the given id" do
      do_request
      expect(assigns :task).to eq(task)
    end

    it "renders the show template" do
      do_request
      expect(response).to render_template(:show)
    end

    it "uses the overlay layout" do
      do_request
      expect(response).to render_template(layout: :overlay)
    end

    context "json requests" do
      let(:format) { :json }

      it "requests the proper task presenter" do
        allow(TaskPresenter).to receive(:for).and_call_original
        do_request
        expect(TaskPresenter).to have_received(:for).with task
      end

      it "renders task's data attributes in JSON" do
        do_request
        data_attributes = JSON.parse response.body
        expect(data_attributes).to eq TaskPresenter.for(task).data_attributes
      end
    end
  end

  describe 'MessageTask' do

    let(:user) { FactoryGirl.create :user, admin: super_admin }
    let(:super_admin) { false }
    before { sign_in user }

    describe "POST 'create'" do

      let(:paper) { FactoryGirl.create :paper, user: user }
      let(:msg_subject) { "A Subject" }
      subject(:do_request) do
        post :create, format: 'json',
          paper_id: paper.id,
          phase_id: paper.phases.first.id,
          task: {message_subject: msg_subject,
                 message_body: "My body",
                 participant_ids: [user.id]}
      end

      def verify_response(response)
          json = JSON.parse(response.body)
          expect(json["cardName"]).to eq("message")
          expect(json["messageSubject"]).to eq(msg_subject)
          expect(json["taskTitle"]).to eq(msg_subject)
          expect(json["comments"].count).to eq(1)
      end
      context "with a paper that the user administers through a journal" do
        let!(:journal_role) do
          paper.journal.journal_roles.create!(user: user, admin: true)
        end

        it "renders the new message as json." do
          do_request
          expect(response).to be_success
          verify_response(response)
        end

        context "with no subject" do
          let(:msg_subject) { nil }
          it "returns an error" do
            do_request
            expect(response.status).to eq(400)
            expect(JSON.parse(response.body)).to have_key("errors")
          end
        end
      end

      context "when the user doesn't administer the paper directly" do
        context "the user isn't a super admin" do
          it "renders 404" do
            do_request
            expect(response.status).to eq(404)
          end
        end

        context "the user is a super admin" do
          let(:super_admin) { true }
          it "renders the new message" do
            do_request
            expect(response).to be_success
            verify_response(response)
          end
        end
      end
    end
  end
end
