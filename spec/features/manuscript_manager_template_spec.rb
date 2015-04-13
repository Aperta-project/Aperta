require 'rails_helper'

feature "Manuscript Manager Templates", js: true, selenium: true do
  let(:admin) { create :user, :site_admin }
  let!(:journal) { create :journal }

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in admin

    within ".navigation" do
      click_link "Admin"
    end
    within ".journal" do
      click_link journal.name
    end
  end

  scenario "Managing the manuscript manager template" do
    journal_page = JournalPage.new
    mmt_page = journal_page.add_new_template
    mmt_page.paper_type = "Test Type"
    expect(mmt_page).to have_phase_names('Phase 1', 'Phase 2', 'Phase 3')

    # adding a phase template
    phase = mmt_page.find_phase 'Phase 1'
    phase.rename 'F1rst Ph4ze'
    expect { phase.add_phase }.to change { mmt_page.phases.count }.by(1)

    # adding a card template
    phase = mmt_page.find_phase 'Phase 2'
    phase.new_card overlay: ChooseCardTypeOverlay, card_type: "Reviewer Report"
    expect(phase).to have_card("Reviewer Report")
    expect(mmt_page).to have_content("SAVE TEMPLATE")
    mmt_page.save
    expect(mmt_page).to have_no_content("SAVE TEMPLATE")
    expect(page.current_url).to match(%r{/admin/journals/\d+/manuscript_manager_templates/\d+/edit})
    expect(mmt_page).to have_no_application_error

    # adding a card to an existing mmt is autosaved
    mmt_page = ManuscriptManagerTemplatePage.new
    phase = mmt_page.find_phase 'Phase 2'
    phase.new_card overlay: ChooseCardTypeOverlay, card_type: "Assign Admin"
    click_link "Admin"
    find('.journal-thumbnail').click
    find('.blue-box', text: 'Test Type').hover
    find('.blue-box .glyphicon-pencil', visible: true).click

    expect(find('.card-content', text: "Assign Admin")).to be_present
  end
end
