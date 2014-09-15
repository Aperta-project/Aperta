require 'spec_helper'

feature 'Add a new card', js: true do
  let(:admin) { create :user, admin: true }

  let(:journal) { FactoryGirl.create :journal }
  let(:paper) do
    FactoryGirl.create :paper, :with_tasks, user: admin, submitted: true, journal: journal
  end

  let!(:albert) { create :user }

  before do
    assign_journal_role(journal, albert, :admin)
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in admin
  end

  scenario "Admin can add a new card" do
    task_manager_page = TaskManagerPage.visit paper

    needs_editor_phase = task_manager_page.phase 'Assign Editor'
    card = needs_editor_phase.new_card overlay: NewAdhocCardOverlay,
      title: 'Verify Author Signatures'

    expect(card.title).to eq 'Verify Author Signatures'
  end
end
