require 'rails_helper'

feature "Register Decision", js: true, selenium: true do

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

  scenario "Completed card cannot be modified" do
    dashboard_page = DashboardPage.new
    manuscript_page = dashboard_page.view_submitted_paper paper
    manuscript_page.view_card 'Register Decision' do |overlay|
      overlay.register_decision = "Accepted"
      overlay.decision_letter = "Accepting this because I can"
      overlay.mark_as_complete
      check "Completed"
      expect(overlay).to be_completed

      # assert the overlay is not editable
      overlay.register_decision = "Rejected" # should not be able to select
      expect(find(".decision-label input[value='accepted']")[:checked]).to eq "true"
    end
  end
end
