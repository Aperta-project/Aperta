require 'spec_helper'

describe TasksController, redis: true do
  let(:user) { create :user, :site_admin }

  let!(:paper) do
    FactoryGirl.create(:paper, :with_tasks, user: user)
  end

  before do
    sign_in user
    allow(EventStream).to receive(:post_event)
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

    subject(:do_request) do
      xhr :patch, :update, { format: 'json', paper_id: paper.to_param, id: task.to_param, task: { completed: '1' } }
    end

    it_behaves_like "an unauthenticated json request"

    it "updates the task" do
      do_request
      expect(task.reload).to be_completed
    end

    it "posts an event to the event stream" do
      do_request
      task.reload
      ts = TaskSerializer.new(task)
      expect(EventStream).to have_received(:post_event).at_least(:once)
    end

    it "renders the task id and completed status as JSON" do
      do_request
      expect(response.status).to eq(204)
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
  end

  describe "GET 'show'" do
    let(:paper) { FactoryGirl.create(:paper, :with_tasks, user: user) }
    let(:task) { paper.tasks.first }

    subject(:do_request) { get :show, { id: task.id, format: format } }

    context "html requests" do
      let(:format) { nil }
      it_behaves_like "when the user is not signed in"
    end

    context "json requests" do
      let(:format) { :json }

      it "calls the Task subclass's appropriate serializer when rendering JSON" do
        do_request
        data_attributes = JSON.parse response.body
        serializer = task.active_model_serializer.new(task)
        expect(data_attributes.keys).to match_array(serializer.as_json.stringify_keys.keys)
      end
    end
  end

  describe "PUT 'send_message'" do
    let(:paper) { FactoryGirl.create(:paper, :with_tasks, user: user) }
    let(:task) { paper.tasks.first }

    subject(:do_request) { put :send_message, { id: task.id, format: "json", task: {subject: "Hello", body: "Greetings from Vulcan!", recepients: [user.id]} } }

    it "adds an email to the SideKiq queue" do
      expect { do_request }.to change(Sidekiq::Extensions::DelayedMailer.jobs, :size).by(1)
    end
  end

  describe 'MessageTask' do

    let(:user) { FactoryGirl.create :user, site_admin: super_admin }
    let(:super_admin) { false }
    before { sign_in user }

    describe "POST 'create'" do
      # For now a user has to be an admin to create a new message task
      let(:super_admin) { true }
      let(:msg_subject) { "A Subject" }
      subject(:do_request) do
        xhr :post, :create, format: 'json',
          paper_id: paper.id,
          task: {title: msg_subject,
                 type: 'MessageTask',
                 phase_id: paper.phases.first.id,
                 message_body: "My body",
                 participant_ids: [user.id]}
      end

      context "with a paper that the user administers through a journal" do
        before do
          assign_journal_role(paper.journal, user, :admin)
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
          it "renders a 403" do
            do_request
            expect(response.status).to eq(403)
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
