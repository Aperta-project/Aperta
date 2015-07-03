require 'rails_helper'

feature "Register Decision", js: true do
  let(:user) { FactoryGirl.create(:user) }
  let(:task) { FactoryGirl.create(:register_decision_task) }
  let!(:paper) do
    task.paper.update_attributes({
      creator:  user,
      publishing_state: "submitted"
    })
    task.paper
  end
  let(:dashboard_page) { DashboardPage.new }

  before do
    task.participants << user
    paper.paper_roles.create!(user: user, role: PaperRole::COLLABORATOR)
    login_as user
    visit "/"
  end

  context "Registering a decision on a paper" do
    let(:manuscript_page) { dashboard_page.view_submitted_paper paper }

    scenario "Participant registers a decision on the paper" do
      manuscript_page.view_card 'Register Decision' do |overlay|
        overlay.register_decision = "Accepted"
        overlay.decision_letter = "Accepting this because I can"
        overlay.click_send_email_button
        expect(overlay).to be_completed
      end
    end

    scenario "Disable inputs upon card completion" do
      manuscript_page.view_card 'Register Decision' do |overlay|
        overlay.register_decision = "Accepted"
        overlay.decision_letter = "Accepting this because I can"
        overlay.click_send_email_button
        expect(overlay).to be_completed
        expect(overlay.find(".alert-info").text).to eq("A final Decision of accepted has been registered.")
        expect(overlay).to be_disabled
      end
    end

    scenario "persist the decision radio button" do
      manuscript_page.view_card 'Register Decision' do |overlay|
        overlay.register_decision = "Rejected"
        overlay.radio_selected?
      end

      visit current_path # Revisit
      manuscript_page.view_card 'Register Decision' do |overlay|
        expect(find("input[value='rejected']")).to be_checked
      end
    end

    context "with a non submitted Paper" do
      scenario "display flash message and disable card" do
        manuscript_page.view_card 'Register Decision' do |overlay|
          overlay.register_decision = "Rejected"
          overlay.radio_selected?
        end

        visit current_path # Revisit
        manuscript_page.view_card 'Register Decision' do |overlay|
          expect(find("input[value='rejected']")).to be_checked
        end
      end
    end
  end

  scenario "User checks previous decision history" do
    paper.decisions.first.update! verdict: "revise",
                                  letter: "Please revise the manuscript"
    paper.decisions.create!
    paper.reload

    manuscript_page = dashboard_page.view_submitted_paper paper

    manuscript_page.view_card 'Register Decision' do |overlay|
      expect(overlay.previous_decisions).to_not be_empty
      expect(overlay.previous_decisions.first.revision_number).to eq("0")
      overlay.find("#accordion h4.panel-title a").click # open Accordion
      expect(overlay.previous_decisions.first.letter).to eq("Request for Revision: Please revise the manuscript")
    end
  end
end
