require 'spec_helper'

feature "Journal Administration", js: true do
  let(:admin) { create :user, :admin }
  let!(:journal) { create :journal }
  let!(:another_journal) { create :journal }

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in admin
  end

  let(:admin_page) { AdminDashboardPage.visit }
  let(:journal_page) { admin_page.visit_journal(journal) }

  describe "Admin root" do
    scenario "Viewing available journals" do
      journal_names = [journal, another_journal].map(&:name)
      expect(admin_page.journal_names).to match_array(journal_names)
    end

    context "when the user is not an admin" do
      let(:admin) { create :user }
      scenario "user is redirected to the dashboard page" do
        visit AdminDashboardPage.path
        expect(page).to have_text "Welcome,"
        expect(page).to_not have_text "Journal Administration"
      end
    end
  end

  describe "Visiting a journal" do
    scenario "shows manuscript manager templates" do
      mmt_names = journal.manuscript_manager_templates.pluck(:paper_type)
      expect(journal_page.mmt_names).to match_array(mmt_names)
    end

    scenario "editing a MMT" do
      mmt = journal.manuscript_manager_templates.first
      mmt_page = journal_page.visit_mmt(mmt)
      expect(mmt_page.paper_type).to eq(mmt.paper_type)
    end

    scenario "deleting a MMT" do
      mmt = journal.manuscript_manager_templates.first
      mmt_to_delete = FactoryGirl.create(:manuscript_manager_template, journal: journal)
      journal_page.delete_mmt(mmt_to_delete)
      expect(journal_page.mmt_names).to_not include(mmt_to_delete.paper_type)
    end

    describe "Interacting with roles" do
      let!(:existing_role) { FactoryGirl.create(:role, journal: journal) }

      scenario "adding a role" do
        role = journal_page.add_role
        role.name = "whatever"
        role.save
        expect(role.name).to eq("whatever")
      end

      scenario "modifying a role" do
        role = journal_page.find_role(existing_role.name)
        expect(role.name).to eq(existing_role.name)
        role.edit
        role.name = "a different name"
        role.save
        expect(role.name).to eq("a different name")
      end

      scenario "deleting a role" do
        role = journal_page.find_role(existing_role.name)
        role.delete
        expect(page).to have_no_content(existing_role.name)

        # the role has been deleted from tne page
        expect { role.name }.to raise_error(Selenium::WebDriver::Error::StaleElementReferenceError)
      end
    end
  end
end
