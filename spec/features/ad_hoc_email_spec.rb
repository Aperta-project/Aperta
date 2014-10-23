require 'spec_helper'

feature 'Ad Hoc Emails', js: true do
  let(:admin) { create :user, :site_admin }

  let(:journal) { FactoryGirl.create :journal }
  let(:paper) do
    FactoryGirl.create :paper, :with_tasks, user: admin, submitted: true, journal: journal
  end
  let!(:task) { FactoryGirl.create :task, :with_participant, phase: paper.phases.first, title: "Ad Hoc" }

  let!(:albert) { create :user }

  before do
    assign_journal_role(journal, albert, :admin)
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in admin
  end

  scenario "User can save an email" do
    task_manager_page = TaskManagerPage.visit paper

    needs_editor_phase = task_manager_page.phase paper.phases.first.name
    needs_editor_phase.view_card("Ad Hoc", NewAdhocCardOverlay) do |card|
      card.create_email(subject: "Hello", body: "OMG EMAIL")
    end
  end
end

