require 'rails_helper'

describe TahiStandardTasks::RegisterDecisionController do
  routes { TahiStandardTasks::Engine.routes }

  let(:journal) { FactoryGirl.create(:journal, :with_roles_and_permissions) }
  let(:admin) { FactoryGirl.create :user, :site_admin }
  let(:author) { FactoryGirl.create :author }
  let(:task) { FactoryGirl.create :register_decision_task, paper: paper }

  before do
    sign_in admin
  end

  describe "POST #decide" do

    before do
      allow(Task).to receive(:find).with(task.to_param).and_return(task)
    end

    subject(:do_request) do
      post :decide, format: :json, id: task.to_param
    end

    context "Paper in a submitted state, with a valid Decision" do
      let(:paper) {
        FactoryGirl.create(:paper, :submitted, :with_tasks,
          title: 'Science - the Complete Works',
          journal: journal,
          creator: admin)
      }

      before do
        paper.decisions.first.update(verdict: "major_revision")
      end

      it "invoke complete_decision on task" do
        expect(task).to receive(:complete_decision)
        do_request
      end

      it "invoke send_email on task" do
        expect(task).to receive(:send_email)
        do_request
      end

      it "creates an activity" do
        activity = {
          subject: paper,
          message: "Major Revision was sent to author"
        }
        expect(Activity).to receive(:create).with(hash_including(activity))
        do_request
      end

      it "return head ok" do
        do_request
        expect(response).to be_success
      end
    end

    context "Paper in a non-submitted state" do
      let(:paper) {
        FactoryGirl.create(:paper, :with_tasks,
          title: 'Work in Progress',
          journal: journal,
          creator: admin)
      }

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
        expect(res_body["error"]).to eq "Invalid Task and/or Paper"
      end
    end
  end
end
