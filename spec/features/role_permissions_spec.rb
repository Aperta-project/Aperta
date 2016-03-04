require 'rails_helper'

feature 'journal admin old_role', js: true do
  let(:user) { create :user }
  let!(:journal) { create :journal, :with_roles_and_permissions }
  let!(:another_journal) { create :journal, :with_roles_and_permissions }

  let(:dashboard) { DashboardPage.new }

  context 'non-admin user with journal admin old_role' do
    before do
      assign_journal_role(journal, user, :admin)
      login_as(user, scope: :user)
      visit "/"
    end

    scenario 'the user can see admin-y links' do
      # the user can see the admin link on the dashboard
      expect(dashboard.admin_link).to be_present

      # the user can view the admin page for a journal
      admin_page = dashboard.visit_admin
      expect(admin_page).to have_journal_name(journal.name)
      admin_page.visit_journal(journal)
    end
  end

  context 'non-admin user without journal admin old_role' do
    before do
      login_as(user, scope: :user)
      visit "/"
    end

    scenario 'the user does not see the admin link on the dashboard' do
      expect(dashboard).to have_no_admin_link
    end
  end
end
