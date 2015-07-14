require 'rails_helper'

describe TahiStandardTasks::RegisterDecisionController do
  routes { TahiStandardTasks::Engine.routes }

  let(:journal) { FactoryGirl.create(:journal) }
  let(:admin) { FactoryGirl.create :user, :site_admin }
  let(:author) { FactoryGirl.create :author }
  let(:task) { FactoryGirl.create :register_decision_task, paper: paper }

  before do
    sign_in admin
  end

  describe "#decide" do
    context "Paper in a submitted state, with a valid Decision" do
      let(:paper) {
        FactoryGirl.create(:paper, :submitted, :with_tasks,
          short_title: 'Submitted Paper',
          title: 'Science - the Complete Works',
          journal: journal,
          creator: admin)
      }

      before do
        paper.decisions.first.update(verdict: "revise")
        post :decide, format: :json, id: task.id
      end

      pending("expect task.complete_decision to be called")

      pending("expect task.send_email to be called")

      it "returns 200 - success" do
        expect(response.status).to eq 200
        expect(res_body["success"]).to eq true
      end
    end

    context "Paper in a non-submitted state" do
      let(:paper) {
        FactoryGirl.create(:paper, :with_tasks,
          short_title: 'Non-submitted Paper',
          title: 'Work in Progress',
          journal: journal,
          creator: admin)
      }

      before do
        post :decide, format: :json, id: task.id
      end

      it "returns an error" do
        expect(res_body["error"]).to eq "Invalid Task and/or Paper"
      end
    end
  end
end
