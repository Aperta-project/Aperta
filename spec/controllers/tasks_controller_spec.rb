require 'spec_helper'

class FakeTask < Task
  PERMITTED_ATTRIBUTES = [{ some_attribute: [some_value: []] }]
end

describe TasksController do
  let(:permitted_params) { [:assignee_id, :completed, :title, :body, :phase_id, :type] }

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

  describe "POST 'create'" do
    let!(:paper) { Paper.create! short_title: 'some-paper', journal: Journal.create!, user: user }

    subject(:do_request) do
      post :create, { format: 'json', paper_id: paper.to_param, task: { assignee_id: '1',
                                                        type: 'Task',
                                                        phase_id: paper.task_manager.phases.last.id,
                                                        title: 'Verify Signatures',
                                                        body: 'Seriously, do it!' } }
    end

    it_behaves_like "an unauthenticated json request"

    it_behaves_like "a controller enforcing strong parameters" do
      let(:params_id) { task.to_param }
      let(:paper_id) { paper.to_param }
      let(:model_identifier) { :task }
      let(:expected_params) { permitted_params }
      let(:returned_params) { {type: "Task"} }
    end

    it "creates a task" do
      expect { do_request }.to change(Task, :count).by 1
    end
  end

  describe "PATCH 'update'" do
    let(:paper) { Paper.create! short_title: 'paper-yet-to-be-updated', journal: Journal.create!, user: user }
    let(:task) { Task.create! title: "sample task", role: "sample role", phase: paper.task_manager.phases.first }

    subject(:do_request) do
      patch :update, { format: 'json', paper_id: paper.to_param, id: task.to_param, task: { completed: '1' } }
    end

    it_behaves_like "an unauthenticated json request"

    it_behaves_like "a controller enforcing strong parameters" do
      let(:params_id) { task.to_param }
      let(:paper_id) { paper.to_param }

      let(:model_identifier) { :task }
      let(:expected_params) { permitted_params }
    end

    describe "subclasses of task" do
      let(:task) { FakeTask.create! title: "sample task", role: "sample role", phase: paper.task_manager.phases.first }
      let(:permitted_params) { [:assignee_id, :completed, :title, :body, :phase_id, :type, some_attribute: [some_value: []]] }

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
        expect(response.status).to eq(204)
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
    let(:paper_admin_task) { Task.where(title: "Assign Admin").first }

    let(:format) { nil }

    it_behaves_like "when the user is not signed in"

    subject(:do_request) { get :show, { id: paper_admin_task.id, paper_id: paper.id, format: format } }

    context "json requests" do
      let(:format) { :json }

      it "calls the Task subclass's appropriate serializer when rendering JSON" do
        do_request
        data_attributes = JSON.parse response.body
        expect(data_attributes.keys).to match_array(PaperAdminTaskSerializer.new(paper_admin_task).as_json.stringify_keys.keys)
      end
    end
  end

  describe 'MessageTask' do

    let(:user) { FactoryGirl.create :user, admin: super_admin }
    let(:super_admin) { false }
    before { sign_in user }

    describe "POST 'create'" do
      # For now a user has to be an admin to create a new message task
      let(:super_admin) { true }
      let(:paper) { FactoryGirl.create :paper, user: user }
      let(:msg_subject) { "A Subject" }
      subject(:do_request) do
        post :create, format: 'json',
          paper_id: paper.id,
          task: {title: msg_subject,
                 type: 'MessageTask',
                 phase_id: paper.phases.first.id,
                 message_body: "My body",
                 participant_ids: [user.id]}
      end

      context "with a paper that the user administers through a journal" do
        let!(:journal_role) do
          paper.journal.journal_roles.create!(user: user, admin: true)
        end

        it "renders the new message as json." do
          do_request
          expect(response.status).to eq(201)
        end

        context "with no subject" do
          let(:msg_subject) { nil }
          it "returns an error" do
            do_request
            expect(response.status).to eq(422)
            expect(JSON.parse(response.body)).to have_key("errors")
          end
        end
      end

      context "when the user doesn't administer the paper directly" do
        context "the user isn't a super admin" do
          let(:super_admin) { false }
          it "renders a 302" do
            do_request
            expect(response.status).to eq(302)
          end
        end

        context "the user is a super admin" do
          let(:super_admin) { true }
          it "renders the new message" do
            do_request
            expect(response.status).to eq(201)
          end
        end
      end
    end
  end
end
