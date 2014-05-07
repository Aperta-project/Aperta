require 'spec_helper'

feature "Tahi administration", js: true do
  let(:admin) { create :user, admin: true }
  let!(:user) { create :user }
  let!(:journal) { create :journal }
  let!(:journal2) { create :journal }

  before { SignInPage.visit.sign_in admin.email }

  scenario "Admin can toggle the super admin bit on other users" do
    admin_page = DashboardPage.visit.visit_admin
    users_page = admin_page.navigate_to 'Users'

    edit_user_page = users_page.edit_user user.id
    expect(edit_user_page).to_not be_admin

    users_page = edit_user_page.set_admin.save

    edit_user_page = users_page.edit_user user.id
    expect(edit_user_page).to be_admin
  end

  scenario "Admin can toggle the admin bit on other users" do
    admin_page = DashboardPage.visit.visit_admin

    roles_page = admin_page.navigate_to 'Journal roles'

    new_roles_page = roles_page.add_role

    new_roles_page.user = user.full_name
    new_roles_page.journal = journal.name

    new_roles_page.set_admin
    roles_page = new_roles_page.save

    edit_role_page = roles_page.edit_role user.full_name, journal.name
    expect(edit_role_page).to be_admin
    expect(edit_role_page).to_not be_editor
    expect(edit_role_page).to_not be_reviewer
    roles_page = edit_role_page.cancel
  end

  scenario "Admin can toggle editor and reviewer bits on other users" do
    admin_page = DashboardPage.visit.visit_admin
    roles_page = admin_page.navigate_to 'Journal roles'

    new_roles_page = roles_page.add_role

    new_roles_page.user = user.full_name
    new_roles_page.journal = journal.name

    new_roles_page.set_editor
    roles_page = new_roles_page.save

    new_roles_page = roles_page.add_role

    new_roles_page.user = user.full_name
    new_roles_page.journal = journal2.name

    new_roles_page.set_reviewer
    roles_page = new_roles_page.save

    edit_role_page = roles_page.edit_role user.full_name, journal.name
    expect(edit_role_page).to be_editor
    expect(edit_role_page).to_not be_reviewer
    expect(edit_role_page).to_not be_admin

    roles_page = edit_role_page.cancel

    edit_role_page = roles_page.edit_role user.full_name, journal2.name
    expect(edit_role_page).to be_reviewer
    expect(edit_role_page).to_not be_editor
    expect(edit_role_page).to_not be_admin
  end

  scenario "Admin can upload a logo for the journal" do
    admin_page = DashboardPage.visit.visit_admin
    journals_page = admin_page.navigate_to 'Journals'
    edit_journal_page = journals_page.edit_journal journal.id
    edit_journal_page.upload_logo
    journals_page = edit_journal_page.save
    journal_page = journals_page.view_journal journal.id
    expect(journal_page.logo).to end_with 'yeti.jpg'
  end
end
