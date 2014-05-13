require 'spec_helper'

feature "Journal Administration", js: true do
  let(:admin) { create :user, :admin }
  let!(:journal) { create :journal }
  let!(:another_journal) { create :journal }

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in admin
  end

  describe "Admin root" do
    scenario "Viewing available journals" do
      admin_page = AdminDashboardPage.visit
      journal_names = [journal, another_journal].map(&:name)
      expect(admin_page.journal_names).to match_array(journal_names)
    end
  end

  describe "Visiting a journal" do
    scenario "shows manuscript manager templates" do
      admin_page = AdminDashboardPage.visit
      journal_page = admin_page.visit_journal(journal)
      mmt_names = journal.manuscript_manager_templates.pluck(:paper_type)
      expect(journal_page.mmt_names).to match_array(mmt_names)
    end

    scenario "editing a MMT" do
      admin_page = AdminDashboardPage.visit
      journal_page = admin_page.visit_journal(journal)
      mmt = journal.manuscript_manager_templates.first
      mmt_page = journal_page.visit_mmt(mmt)
      expect(mmt_page.paper_type).to eq(mmt.paper_type)
    end

    scenario "deleting a MMT" do
      mmt = journal.manuscript_manager_templates.first
      mmt_to_delete = FactoryGirl.create(:manuscript_manager_template, journal: journal)
      admin_page = AdminDashboardPage.visit
      journal_page = admin_page.visit_journal(journal)
      journal_page.delete_mmt(mmt_to_delete)
      expect(journal_page.mmt_names).to_not include(mmt_to_delete.paper_type)
    end
  end
end
