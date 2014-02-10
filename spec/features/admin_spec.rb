require 'spec_helper'

feature "Tahi administration", js: true do
  let(:admin) do
    User.create! username: 'albert',
      first_name: 'albert',
      last_name: 'einstein',
      email: 'einstein@example.org',
      password: 'password',
      password_confirmation: 'password',
      affiliation: 'universität zürich',
      admin: true
  end

  let!(:user) do
    User.create! username: 'neil',
      first_name: 'Neil',
      last_name: 'Bohrs',
      email: 'neil@example.org',
      password: 'password',
      password_confirmation: 'password',
      affiliation: 'universität zürich'
  end

  let!(:journal) do
    Journal.create! name: 'Journal 1'
  end

  before do
    Journal.create! name: 'Journal 2'
    SignInPage.visit.sign_in admin.email
  end

  scenario "Admin can toggle the admin bit on other users" do
    admin_page = DashboardPage.visit.visit_admin

    users_page = admin_page.navigate_to 'Users'

    edit_user_page = users_page.edit_user user.id
    expect(edit_user_page).to_not be_admin

    users_page = edit_user_page.set_admin.save

    edit_user_page = users_page.edit_user user.id
    expect(edit_user_page).to be_admin
  end

  scenario "Admin can toggle editor and reviewer bits on other users" do
    admin_page = DashboardPage.visit.visit_admin
    roles_page = admin_page.navigate_to 'Journal roles'

    new_roles_page = roles_page.add_role

    new_roles_page.user = user.full_name
    new_roles_page.journal = 'Journal 1'

    new_roles_page.set_editor
    roles_page = new_roles_page.save

    new_roles_page = roles_page.add_role

    new_roles_page.user = user.full_name
    new_roles_page.journal = 'Journal 2'

    new_roles_page.set_reviewer
    roles_page = new_roles_page.save

    edit_role_page = roles_page.edit_role user.full_name, 'Journal 1'
    expect(edit_role_page).to be_editor
    expect(edit_role_page).to_not be_reviewer
    roles_page = edit_role_page.cancel

    edit_role_page = roles_page.edit_role user.full_name, 'Journal 2'
    expect(edit_role_page).to_not be_editor
    expect(edit_role_page).to be_reviewer
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
