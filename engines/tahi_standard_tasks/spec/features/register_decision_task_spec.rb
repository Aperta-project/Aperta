require 'rails_helper'

feature "Register Decision", js: true do

  let(:user) { FactoryGirl.create(:user) }
  let(:task) { FactoryGirl.create(:register_decision_task) }
  let!(:paper) do
    task.paper.update_attribute(:creator, user)
    task.paper
  end

  before do
    task.participants << user
    paper.paper_roles.create!(user: user, role: PaperRole::COLLABORATOR)
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in(user)
  end

  scenario "Participant registers a decision on the paper" do
    dashboard_page = DashboardPage.new
    manuscript_page = dashboard_page.view_submitted_paper paper
    manuscript_page.view_card 'Register Decision' do |overlay|
      overlay.register_decision = "Accepted"
      overlay.decision_letter = "Accepting this because I can"
      overlay.mark_as_complete
      expect(overlay).to be_completed
    end
  end

  scenario "Disable inputs upon card completion" do
    dashboard_page = DashboardPage.new
    manuscript_page = dashboard_page.view_submitted_paper paper
    manuscript_page.view_card 'Register Decision' do |overlay|
      overlay.register_decision = "Accepted"
      overlay.decision_letter = "Accepting this because I can"
      overlay.mark_as_complete
      expect(overlay).to be_completed
      expect(overlay.find(".alert-info").text).to eq("A final Decision of accepted has been registered.")
      expect(overlay).to be_disabled
    end
  end

  scenario "User checks previous decision history" do
    paper.decisions.first.update! verdict: "revise",
                                  letter: "Please revise the manuscript"
    paper.decisions.create!
    paper.reload

    dashboard_page = DashboardPage.new
    manuscript_page = dashboard_page.view_submitted_paper paper

    manuscript_page.view_card 'Register Decision' do |overlay|
      expect(overlay.previous_decisions).to_not be_empty
      expect(overlay.previous_decisions.first.revision_number).to eq("0")
      overlay.find("#accordion h4.panel-title a").click # open Accordion
      expect(overlay.previous_decisions.first.letter).to eq("Please revise the manuscript")
    end
  end
end
