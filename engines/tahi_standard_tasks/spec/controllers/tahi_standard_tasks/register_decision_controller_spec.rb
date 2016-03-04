require 'rails_helper'

describe TahiStandardTasks::RegisterDecisionController do
  routes { TahiStandardTasks::Engine.routes }

  let(:journal) { FactoryGirl.create(:journal, :with_roles_and_permissions) }
  let(:user) { FactoryGirl.create :user }
  let(:creator) { FactoryGirl.create :user }
  let(:task) { FactoryGirl.create :register_decision_task, paper: paper }

  before do
    stub_sign_in(user)
  end

  describe "POST #decide" do
    let(:can_register_decision) { true }

    before do
      allow(user).to(
        receive(:can?)
        .with(:register_decision, paper)
        .and_return(can_register_decision))
      allow(Task).to receive(:find).with(task.to_param).and_return(task)
    end

    subject(:do_request) do
      post :decide, format: :json, id: task.to_param
    end

    context "Paper in a submitted state, with a valid Decision" do
      let(:paper) do
        FactoryGirl.create(
          :paper, :submitted, :with_tasks,
          title: 'Science - the Complete Works',
          journal: journal)
      end

      before do
        paper.decisions.first.update(verdict: "major_revision")
      end

      it "invoke complete_decision on task" do
        expect(task).to receive(:complete_decision)
        do_request
        expect(response).to be_success
      end

      it "invoke send_email on task" do
        expect(task).to receive(:send_email)
        do_request
        expect(response).to be_success
      end

      it "creates an activity" do
        activity = {
          subject: paper,
          message: "Major Revision was sent to author"
        }
        expect(Activity).to receive(:create).with(hash_including(activity))
        do_request
        expect(response).to be_success
      end

      context 'user does not have :can_register_decision permission' do
        let(:can_register_decision) { false }
        it 'returns 403 status' do
          do_request
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context "Paper in a non-submitted state" do
      let(:paper) do
        FactoryGirl.create(
          :paper, :with_tasks,
          title: 'Work in Progress',
          journal: journal)
      end

      it "does not invoke complete_decision on task" do
        expect(task).to_not receive(:complete_decision)
        do_request
      end

      it "does not invoke send_email on task" do
        expect(task).to_not receive(:send_email)
        do_request
      end

      it "returns an error" do
        do_request
        expect(res_body["errors"]).to eq "errors" => ["Invalid Task and/or Paper"]
      end
    end
  end
end
