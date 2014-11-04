require 'spec_helper'

feature "Manuscript Manager Templates", js: true, selenium: true do
  let(:admin) { create :user, :site_admin }
  let(:journal) { create :journal }

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in admin
  end

  describe "Adding phases" do
    scenario "Adding a phase" do
      journal_page = JournalPage.visit(journal)
      mmt_page = journal_page.add_new_template
      expect(mmt_page.phases).to match_array ['Phase 1', 'Phase 2', 'Phase 3']

      phase = mmt_page.find_phase 'Phase 1'
      phase.rename 'F1rst Ph4ze'
      expect { phase.add_phase }.to change { mmt_page.phases.count }.by(1)
    end
  end

  describe "Adding cards" do
    scenario "Adding a card" do
      journal_page = JournalPage.visit(journal)
      mmt_page = journal_page.add_new_template
      mmt_page.paper_type = "Test Type"
      phase = mmt_page.find_phase 'Phase 1'
      phase.new_card overlay: ChooseCardTypeOverlay, card_type: "Reviewer Report"
      expect(phase).to have_card("Reviewer Report")
      expect(mmt_page).to have_content("SAVE TEMPLATE")
      mmt_page.save
      expect(mmt_page).to have_no_content("SAVE TEMPLATE")
      expect(page.current_url).to match(%r{/admin/journals/\d+/manuscript_manager_templates/\d+/edit})
      expect(mmt_page).to have_no_application_error
    end

    scenario "Adding a card without saving" do
      journal_page = JournalPage.visit(journal)
      mmt_page = journal_page.add_new_template
      mmt_page.paper_type = "Test Type"
      phase = mmt_page.find_phase 'Phase 1'
      phase.new_card overlay: ChooseCardTypeOverlay, card_type: "Reviewer Report"
      expect(phase).to have_card("Reviewer Report")
      expect(mmt_page).to have_content("SAVE TEMPLATE")

      click_link 'Admin'
      overlay = UnsavedChanges.find_overlay(mmt_page)
      overlay.discard_changes
      expect(current_path).to eq("/admin")
    end
  end
end


