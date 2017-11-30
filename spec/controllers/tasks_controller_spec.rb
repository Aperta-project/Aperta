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
      :with_phases,
      :submitted,
      creator: user,
      journal: journal
    )
  end

  describe "GET #index" do
    subject(:do_request) do
      get :index, format: 'json',
                  paper_id: paper.to_param
    end
    let(:tasks) { [FactoryGirl.create(:ad_hoc_task, paper: paper)] }

    it_behaves_like "an unauthenticated json request"

    context "when the user has access" do
      before do
        stub_sign_in(user)

        allow(user).to receive(:can?)
          .with(:view, paper)
          .and_return true

        allow(user).to receive(:can?)
          .with(:view, tasks[0])
          .and_return true
      end

      it "returns only the paper's tasks the user has access to" do
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

  describe "POST #create" do
    let(:task_params) do
      {
        type: 'PlosBilling::BillingTask',
        paper_id: paper.to_param,
        phase_id: paper.phases.last.id,
        title: 'Verify Signatures'
      }
    end

    subject(:do_request) do
      post :create, format: 'json', task: task_params
    end

    it_behaves_like "an unauthenticated json request"

    context "when the user has access" do
      before do
        CardLoader.load("PlosBilling::BillingTask")
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:manage_workflow, paper)
          .and_return true

        allow(user).to receive(:can?)
          .with(:view, Task)
          .and_return true
      end

      it "creates a task" do
        expect { do_request }.to change(Task, :count).by 1
      end

      it "does not create another billing task if a billing task already exists" do
        FactoryGirl.create(:billing_task, paper: paper)
        expect { do_request }.not_to change(Task, :count)
      end

      it "does create another billing task when there are no billing tasks on the paper" do
        expect { do_request }.to change(Task, :count).by 1
      end

      it "uses the TaskFactory to create the new task" do
        expect(TaskFactory).to receive(:create).and_call_original
        do_request
      end

      context "a card_id is included in the params" do
        let(:card) { FactoryGirl.create(:card, :versioned, journal: journal) }
        let(:task_params) do
          {
            type: 'TahiStandardTasks::UploadManuscriptTask',
            paper_id: paper.to_param,
            phase_id: paper.phases.last.id,
            title: card.name,
            card_id: card.id
          }
        end

        it "creates a new task from a card template, using the latest published version" do
          expect(TaskFactory).to(receive(:create)
                                   .with(TahiStandardTasks::UploadManuscriptTask, hash_including(card_version: anything))
                                   .and_call_original)
          expect { do_request }.to change(TahiStandardTasks::UploadManuscriptTask, :count).by(1)
          expect(TahiStandardTasks::UploadManuscriptTask.last.card_version).to eq(card.latest_published_card_version)
        end
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

  describe "PUT #sendback_email" do
    let(:task) { FactoryGirl.create(:ad_hoc_task, paper: paper) }

    subject(:do_request) do
      xhr(
        :put,
        :sendback_email,
        format: 'json',
        id: task.to_param,
        task: {}
      )
    end

    it_behaves_like "an unauthenticated json request"

    context "when the user has access" do
      before do
        FactoryGirl.create(:letter_template, journal: journal, name: 'Sendback Reasons')
        stub_sign_in user
      end

      it "succsefully handles the request" do
        do_request
        expect(response.status).to eq(204)
      end

      it "queues an email" do
        expect { do_request }.to change(Sidekiq::Extensions::DelayedMailer.jobs, :size).by(1)
      end

      it "changes the paper's state to checking" do
        expect(paper.publishing_state).to eq('submitted')
        do_request
        expect(paper.reload.publishing_state).to eq('checking')
      end
    end
  end

  describe "PUT #sendback_preview" do
    let(:task) { FactoryGirl.create(:ad_hoc_task, paper: paper) }

    subject(:do_request) do
      xhr(
        :put,
        :sendback_preview,
        format: 'json',
        id: task.to_param,
        task: {}
      )
    end

    it_behaves_like "an unauthenticated json request"

    context "when the user has access" do
      before do
        FactoryGirl.create(:letter_template, journal: journal, name: 'Sendback Reasons')
        stub_sign_in user
      end

      it "succsefully handles the request" do
        do_request
        expect(response.status).to eq(200)
      end

      it "renders the rendered letter template" do
        do_request
        expect(res_body.keys).to contain_exactly("to", "subject", "body")
        expect(res_body.values).not_to include(nil)
      end
    end
  end

  describe "PATCH #update" do
    let(:task) do
      FactoryGirl.create(:ad_hoc_task, paper: paper, phase: paper.phases.first)
    end
    let(:task_params) {  { completed: '1' } }

    subject(:do_request) do
      xhr(
        :patch,
        :update, format: 'json',
                 paper_id: paper.to_param,
                 id: task.to_param, task: task_params
      )
    end

    it_behaves_like "an unauthenticated json request"

    context "when the user has access" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, task)
          .and_return true

        allow(user).to receive(:can?)
          .with(:view, task)
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

      it "does not raises an error" do
        do_request
        expect(response.body).not_to include "This paper cannot be edited at this time."
      end

      context 'when the request is marking the task complete' do
        context 'and the task is ready?' do
          it 'marks the task complete' do
            allow(controller).to receive(:task).and_return(task)
            expect(task).to receive(:ready?).and_return(true)
            expect { do_request }.to change { task.reload.completed }.from(false).to(true)
          end
        end
      end

      context "and the task is marked as complete" do
        before do
          task.update_column :completed, true
        end

        it "allows the task to be marked as incomplete" do
          expect do
            task_params.merge!(completed: '0', title: 'vernors')
            do_request
          end.to change { task.reload.completed }.from(true).to(false)
        end

        it "allows assigning an user to the task" do
          expect do
            task_params[:assigned_user_id] = 1
            do_request
          end.to change { task.reload.assigned_user_id }.from(nil).to(1)
        end

        it "allows revoking an user from the task" do
          task.update(assigned_user_id: 11)
          expect do
            task_params[:assigned_user_id] = nil
            do_request
          end.to change { task.reload.assigned_user_id }.from(11).to(nil)
        end

        it "does not incomplete the task when the completed param is not a part of the request" do
          expect do
            task_params = { title: 'vernors' }
            do_request
          end.to_not change { task.reload.completed }
        end

        it "does not update anything else on the task" do
          expect do
            task_params[:title] = 'vernors'
            do_request
          end.to_not change { task.reload.title }
        end
      end
    end

    context "when the user does not have access" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, task)
          .and_return false
      end

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

  describe "GET #show" do
    let(:task) { FactoryGirl.build_stubbed(:ad_hoc_task) }
    subject(:do_request) { get :show, id: task.id, format: :json }
    let(:format) { :json }

    before do
      allow(Task).to receive(:find).with(task.id.to_param).and_return task
    end

    it_behaves_like "an unauthenticated json request"

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

  describe "PUT #send_message" do
    let(:task) { FactoryGirl.build_stubbed(:ad_hoc_task) }

    before do
      allow(Task).to receive(:find).with(task.id.to_param).and_return task
    end

    subject(:do_request) do
      put :send_message, id: task.id, format: "json",
                         task: {
                           subject: "Hello",
                           body: "Greetings from Vulcan!",
                           recipients: [user.id]
                         }
    end

    it_behaves_like "an unauthenticated json request"

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

  describe "DELETE #destroy" do
    let(:task) { FactoryGirl.create(:ad_hoc_task) }

    subject(:do_request) do
      delete :destroy, id: task.id, format: "json"
    end

    it_behaves_like "an unauthenticated json request"

    context "when the user has access" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:manage_workflow, task.paper)
          .and_return true
      end

      it "destroys the task" do
        expect do
          do_request
        end.to change { Task.exists?(task.id) }.from(true).to(false)
      end
    end

    context "when the user does not have access" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:manage_workflow, task.paper)
          .and_return false
      end

      it { is_expected.to responds_with(403) }

      it "does not destroy the task" do
        expect do
          do_request
        end.to_not change { Task.exists?(task.id) }.from(true)
      end
    end
  end

  describe "GET #nested_questions" do
    let(:task) { FactoryGirl.create(:billing_task, :with_loaded_card) }
    let!(:card_content) do
      root = task.card.content_root_for_version(:latest)
      root.children.first
    end

    subject(:do_request) do
      get :nested_questions, task_id: task.id, format: "json"
    end

    it_behaves_like "an unauthenticated json request"

    context "when the user has access" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:view, task)
          .and_return true
      end

      it "responds with a list of serialized nested questions" do
        do_request
        response_json = JSON.parse(response.body)
        expect(response_json).to have_key('nested_questions')
        expect(response_json['nested_questions'].first).to eq(
          CardContentAsNestedQuestionSerializer.new(
            card_content
          ).as_json[:nested_question].deep_stringify_keys
        )
      end

      it "responds 200 OK" do
        do_request
        expect(response.status).to be 200
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

  describe "GET #nested_question_answers" do
    let(:task) { FactoryGirl.create(:billing_task, :with_card) }
    let(:card_content) do
      root = Card.find_by(name: task.class.name).content_root_for_version(:latest)
      FactoryGirl.create(:card_content, parent: root)
    end
    let!(:answer) do
      FactoryGirl.create(
        :answer,
        owner: task,
        card_content: card_content,
        paper: task.paper
      )
    end

    subject(:do_request) do
      get :nested_question_answers, task_id: task.id, format: "json"
    end

    it_behaves_like "an unauthenticated json request"

    context "when the user has access" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:view, task)
          .and_return true
      end

      it "responds with a list of serialized nested question answers" do
        do_request
        response_json = JSON.parse(response.body)
        expect(response_json).to have_key('nested_question_answers')
        expect(response_json['nested_question_answers'].first).to eq(
          AnswerAsNestedQuestionAnswerSerializer.new(
            answer
          ).as_json[:nested_question_answer].deep_stringify_keys
        )
      end

      it "responds 200 OK" do
        do_request
        expect(response.status).to be 200
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
