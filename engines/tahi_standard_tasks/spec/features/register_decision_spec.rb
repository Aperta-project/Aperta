require 'rails_helper'

feature "Register Decision", js: true do
  let(:user) { FactoryGirl.create(:user) }
  let(:task) { FactoryGirl.create(:register_decision_task) }
  let!(:paper) do
    task.paper.update_attributes(
      creator: user,
      publishing_state: "submitted"
    )
    task.paper
  end
  let(:dashboard_page) { DashboardPage.new }
  let(:manuscript_page) { dashboard_page.view_submitted_paper paper }

  before do
    task.participants << user
    assign_journal_role paper.journal, user, :editor
    login_as(user, scope: :user)
    visit "/"
  end

  context "Registering a decision on a paper" do
    context "with a non-submitted Paper" do
      before do
        paper.update_attributes(publishing_state: "unsubmitted")
      end

      scenario "Participant registers a decision on the paper" do
        overlay = Page.view_task_overlay(paper, task)
        expect(overlay.invalid_state_message).to be true
        expect(overlay).to be_disabled
      end
    end

    scenario "Participant registers a decision on the paper" do
      overlay = Page.view_task_overlay(paper, task)
      overlay.register_decision = "Accept"
      overlay.decision_letter = "Accepting this because I can"
      overlay.click_send_email_button
      expect(overlay).to be_completed
    end

    scenario "Disable inputs upon card completion" do
      overlay = Page.view_task_overlay(paper, task)
      overlay.register_decision = "Accept"
      overlay.decision_letter = "Accepting this because I can"
      overlay.click_send_email_button
      expect(overlay).to be_completed
      expect(overlay.success_state_message).to be true
      expect(first('input[name=decision]')).to be_disabled
    end

    scenario "persist the decision radio button" do
      overlay = Page.view_task_overlay(paper, task)
      overlay.register_decision = "Reject"
      wait_for_ajax
      overlay.radio_selected?

      visit current_path # Revisit
      overlay = Page.view_task_overlay(paper, task)
      expect(find("input[value='reject']")).to be_checked
    end

    context "with a non submitted Paper" do
      scenario "display flash message and disable card" do
        overlay = Page.view_task_overlay(paper, task)
        overlay.register_decision = "Reject"
        wait_for_ajax
        overlay.radio_selected?

        visit current_path # Revisit
        overlay = Page.view_task_overlay(paper, task)
        expect(find("input[value='reject']")).to be_checked
      end
    end
  end

  context "With previous decision history" do
    before do
      paper.decisions.first.update! verdict: "major_revision",
                                    letter: "Please revise the manuscript.\nAfter line break"
      paper.decisions.create!
      paper.reload
    end

    scenario "User checks previous decision history" do
      overlay = Page.view_task_overlay(paper, task)
      expect(overlay.previous_decisions).to_not be_empty
      expect(overlay.previous_decisions.first.revision_number).to eq("0")
      overlay.find("#accordion h4.panel-title a").click # open Accordion
      expect(overlay.previous_decisions.first.letter).to eq("Please revise the manuscript. After line break")
      expect(overlay.previous_decisions.first.letter).to_not include "<br>"
    end
  end
end
