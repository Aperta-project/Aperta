require 'rails_helper'

feature "Journal Administration", js: true do
  let(:user) { create :user, :site_admin }
  let!(:journal) { create :journal }
  let!(:another_journal) { create :journal }

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in user
  end

  let(:admin_page) { AdminDashboardPage.visit }
  let(:journal_page) { admin_page.visit_journal(journal) }

  describe "journal listing" do
    context "when the user is a site admin" do
      let(:user) { create :user, :site_admin }

      scenario "shows all journals", selenium: true do
        journal_names = [journal, another_journal].map(&:name)
        expect(admin_page.journal_names).to match_array(journal_names)
      end
    end

    context "when the user is a journal admin" do
      let(:user) { create :user }
      before { assign_journal_role(journal, user, :admin) }

      scenario "shows assigned journal" do
        expect(admin_page).to have_journal_names(journal.name)
      end
    end

    context "when the user is not a site admin or journal admin" do
      let(:user) { create :user }

      scenario "redirects to dashboard" do
        visit AdminDashboardPage.path
        expect(page).to have_no_content(AdminDashboardPage.page_header)
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
      expect(mmt_page).to have_paper_type(mmt.paper_type)
    end

    scenario "deleting a MMT" do
      mmt_to_delete = FactoryGirl.create(:manuscript_manager_template, journal: journal)
      journal_page.delete_mmt(mmt_to_delete)
      expect(journal_page).to have_no_mmt_name(mmt_to_delete.paper_type)
    end

    describe "Interacting with roles" do
      let!(:existing_role) { FactoryGirl.create(:role, journal: journal) }

      scenario "adding a role" do
        role = journal_page.add_role
        role.name = "whatever"
        role.save
        # NOTE: `expect(role).to have_name("whatever")` fails.
        # Re-finding it works.
        new_role = journal_page.find_role("whatever")
        expect(new_role).to have_name("whatever")
      end

      scenario "modifying a role" do
        role = journal_page.find_role(existing_role.name)
        expect(role).to have_name(existing_role.name)
        role.edit
        role.name = "a different name"
        role.save
        expect(role).to have_name("a different name")
      end

      scenario "deleting a role", selenium: true do
        role = journal_page.find_role(existing_role.name)
        role.delete
        expect(page).to have_no_content(existing_role.name)

        # the role has been deleted from tne page
        expect { role.name }.to raise_error(Selenium::WebDriver::Error::StaleElementReferenceError)
      end
    end

    describe "on a Journal's Flow Manager" do
      it "show Journal name as text" do
        click_link('Admin')
        click_link(journal.name)
        first(".admin-role-action-button").click
        find("input[name='role[canViewFlowManager]']").set(true)
        click_link("Edit Flows")
        first(".control-bar-link-icon").click
        expect(page.find(".column-title-wrapper")).to have_content journal.name
      end

      describe do
        it "show Journal logo" do
          with_aws_cassette(:yeti_image) do
            journal.update_attributes(logo: File.open("spec/fixtures/yeti.jpg"))
            visit "/admin/journals/1/roles/1/flow_manager"
            find(".control-bar-link-icon").click
            expect(page.find(".column-title-wrapper")).to have_css("img")
          end
        end
      end
    end

  end
end
