require 'spec_helper'

class FakeTask < Task
  PERMITTED_ATTRIBUTES = [{ some_attribute: [some_value: []] }]
end

describe TasksController do

  let(:permitted_params) { [:assignee_id, :completed] }

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

    it "assigns the task manager" do
      do_request
      expect(assigns(:task_manager)).to eq(paper.task_manager)
    end

    it "renders index template" do
      do_request
      expect(response).to render_template(:index)
    end
  end

  describe "PATCH 'update'" do
    let(:paper) { Paper.create! short_title: 'paper-yet-to-be-updated', journal: Journal.create! }
    let(:task) { Task.create! title: "sample task", role: "sample role"}

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
      let(:task) { FakeTask.create! title: "sample task", role: "sample role"}
      let(:permitted_params) { [:assignee_id, :completed, some_attribute: [some_value: []]] }

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
end
