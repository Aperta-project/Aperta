require 'spec_helper'

feature "Journal Administration", js: true do
  let(:user) { create :user, :admin }
  let!(:journal) { create :journal, description: 'journal 1 description' }
  let!(:another_journal) { create :journal, description: 'journal 2 description' }

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in user
  end

  let(:admin_page) { AdminDashboardPage.visit }
  let(:journal_page) { admin_page.visit_journal(journal) }

  scenario "shows a list of journal thumbnails with name and description for each" do
    expect(admin_page.journal_names).to match_array [journal.name, another_journal.name]
    expect(admin_page.journal_descriptions).to match_array [journal.description, another_journal.description]
    expect(admin_page.journal_paper_counts).to match_array [journal.papers.count, another_journal.papers.count]
  end

  describe "editing a journal thumbnail" do
    scenario "shows edit form after clicking on pencil icon" do
      journal_edit_form = admin_page.edit_journal journal
      journal_edit_form.name = "Edited journal"
      # Pending: Create a page fragment for each journal.
    end
  end
end
