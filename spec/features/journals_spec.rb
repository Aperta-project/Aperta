require 'spec_helper'

feature "Journal Administration", js: true do
  let(:user) { create :user, :site_admin }
  let!(:journal) { create :journal, description: 'journal 1 description' }
  let!(:journal2) { create :journal, description: 'journal 2 description' }

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in user
  end

  let(:admin_page) { AdminDashboardPage.visit }
  let(:journal_page) { admin_page.visit_journal(journal) }

  scenario "shows a list of journal thumbnails with name and description for each", selenium: true do
    expect(admin_page.journal_names).to match_array [journal.name, journal2.name]
    expect(admin_page.journal_descriptions).to match_array [journal.description, journal2.description]
    expect(admin_page.journal_paper_counts).to match_array [journal.papers.count, journal2.papers.count]
  end

  describe "creating a journal" do
    scenario "create new journal via new journal form after clicking on 'Add new journal' button" do
      new_journal_form = admin_page.create_journal
      new_journal_form.name = 'New Journal Cool Cool'
      new_journal_form.description = 'New journal description cool cool'
      new_journal_form.save

      expect(admin_page.journal_names).to match_array [journal.name, journal2.name, 'New Journal Cool Cool']
      expect(admin_page.journal_descriptions).to match_array [journal.description, journal2.description, 'New journal description cool cool']

      admin_page.reload sync_on: 'Add new journal'

      expect(admin_page.journal_names).to match_array [journal.name, journal2.name, 'New Journal Cool Cool']
      expect(admin_page.journal_descriptions).to match_array [journal.description, journal2.description, 'New journal description cool cool']
    end
  end

  describe "editing a journal thumbnail", selenium: true do
    scenario "shows edit form after clicking on pencil icon" do
      journal_edit_form = admin_page.edit_journal journal.name
      journal_edit_form.name = "Edited journal"
      journal_edit_form.description = "Edited journal description"
      # FIXME: Waiting on the s3 work to be done
      # journal_edit_form.attach_cover_image 'yeti.jpg', journal.id
      journal_edit_form.save

      journal_edit_form = admin_page.edit_journal "Edited journal"
      journal_edit_form.name = "cancel Edited journal"
      journal_edit_form.description = "cancel Edited journal description"
      journal_edit_form.cancel

      expect(admin_page).to have_journal_names('Edited journal', journal2.name)
      expect(admin_page).to have_journal_descriptions('Edited journal description', journal2.description)

      admin_page.reload sync_on: 'Add new journal'

      expect(admin_page).to have_journal_names('Edited journal', journal2.name)
      expect(admin_page).to have_journal_descriptions('Edited journal description', journal2.description)
    end
  end
end
