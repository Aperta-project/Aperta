require 'spec_helper'

feature "Manuscript Manager Templates", js: true do
  let(:admin) { create :user, :admin }
  let(:journal) { create :journal }

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in admin
  end

  describe "Adding phases" do
    scenario "Adding a phase" do
      mmt_page = ManuscriptManagerTemplatePage.visit(journal)
      mmt_page.add_new_template
      expect(mmt_page.phases).to match_array ['Phase 1', 'Phase 2', 'Phase 3']

      phase = mmt_page.find_phase 'Phase 1'
      phase.rename 'F1rst Ph4ze'
      expect { phase.add_phase }.to change { mmt_page.phases.count }.by(1)
    end
  end

  describe "Adding cards" do
    scenario "Adding a card" do
      mmt_page = ManuscriptManagerTemplatePage.visit(journal)
      mmt_page.add_new_template
      mmt_page.paper_type = "Test Type"
      phase = mmt_page.find_phase 'Phase 1'
      task_type = "ReviewerReportTask"
      phase.new_card overlay: ChooseCardTypeOverlay, card_type: task_type
      expect(phase).to have_card("Reviewer Report Task")
      expect(mmt_page).to have_content("You have unsaved changes")
      mmt_page.save
      expect(mmt_page).to have_no_content("You have unsaved changes")
      expect(page.current_url).to match(%r{/admin/journals/\d+/manuscript_manager_templates/\d+/edit})
      mmt_page.reload
      phase = mmt_page.find_phase 'Phase 1'
      expect(mmt_page.paper_type).to eq("Test Type")
      expect(phase).to have_card("Reviewer Report Task")
    end
  end
end


