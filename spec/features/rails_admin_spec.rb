require 'spec_helper'

feature "Tahi administration", js: true do
  let(:admin) { create :user, admin: true }
  let!(:user) { create :user }
  let!(:journal) { create :journal }
  let!(:journal2) { create :journal }

  before { SignInPage.visit.sign_in admin }

  scenario "Admin can toggle the super admin bit on other users" do
    admin_page = RailsAdminDashboardPage.visit
    users_page = admin_page.navigate_to 'Users'

    edit_user_page = users_page.edit_user user.id
    expect(edit_user_page).to_not be_admin

    users_page = edit_user_page.set_admin.save

    edit_user_page = users_page.edit_user user.id
    expect(edit_user_page).to be_admin
  end

  scenario "Admin can upload a logo for the journal" do
    admin_page = RailsAdminDashboardPage.visit
    journals_page = admin_page.navigate_to 'Journals'
    edit_journal_page = journals_page.edit_journal journal.id
    with_aws_cassette('logo_upload') do
      edit_journal_page.upload_logo
      journals_page = edit_journal_page.save
    end
    journal_page = journals_page.view_journal journal.id
    expect(journal_page.logo).to match /yeti\.jpg/
  end
end
