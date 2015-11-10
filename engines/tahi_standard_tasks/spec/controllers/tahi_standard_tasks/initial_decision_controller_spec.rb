require 'rails_helper'

describe TahiStandardTasks::InitialDecisionController do
  routes { TahiStandardTasks::Engine.routes }

  let(:journal) { FactoryGirl.create(:journal) }
  let(:admin) { FactoryGirl.create :user, :site_admin }
  let(:author) { FactoryGirl.create :author }
  let(:task) { FactoryGirl.create :initial_decision_task, paper: paper }

  before do
    sign_in admin
  end

  describe "POST #create" do

    before do
      allow(Task).to receive(:find).with(task.to_param).and_return(task)
    end

    subject(:do_request) do
      post :create, format: :json, id: task.to_param
    end

    context "Paper in a submitted state, with a valid Decision" do
      let(:paper) do
        FactoryGirl.create(:paper, :submitted, :with_tasks,
                           short_title: 'Submitted Paper',
                           title: 'Science - the Complete Works',
                           journal: journal,
                           creator: admin)
      end

      before do
        paper.decisions.first.update(verdict: "major_revision")
      end

      it "invoke complete_decision on task" do
        expect(task.paper).to receive(:make_decision)
        do_request
      end

      it "sends an email" do
        expect {
          do_request
        }.to change(Sidekiq::Extensions::DelayedMailer.jobs, :size).by(1)
      end
      #
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
  end
end
