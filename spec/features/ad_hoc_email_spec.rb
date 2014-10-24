require 'spec_helper'

feature 'Ad Hoc Emails', js: true do
  let(:admin) { FactoryGirl.create(:user, :site_admin) }
  let(:paper) { FactoryGirl.create(:paper, user: admin) }
  let!(:task) { FactoryGirl.create(:task, :with_participant, paper: paper, title: "Ad Hoc") }

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in admin
  end

  scenario "User can save an email" do
    task_manager_page = TaskManagerPage.visit paper

    needs_editor_phase = task_manager_page.phase(task.phase.name)
    needs_editor_phase.view_card(task.title, NewAdhocCardOverlay) do |card|
      card.create_email(subject: "Hello", body: "Here is an email body")
      card.send_email
      expect(task_manager_page).to have_sent_email
    end
  end
end

