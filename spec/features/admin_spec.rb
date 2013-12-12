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

  before do
    Journal.create! name: 'Journal 1'
    Journal.create! name: 'Journal 2'
    SignInPage.visit.sign_in admin.email
  end

  scenario "Admin can toggle the admin bit on other users" do
    admin_page = DashboardPage.visit.visit_admin

    journal_admin_page = admin_page.visit_journal 'Journal 2'
    users = admin_page.users
    expect(users.size).to eq(2)

    user_record = users.detect { |u| u.id == user.id }
    expect(user_record).to_not be_admin

    user_record.set_admin
    dashboard_page = admin_page.dashboard
    admin_page = dashboard_page.visit_admin

    journal_admin_page = admin_page.visit_journal 'Journal 2'
    user_record = admin_page.users.detect { |u| u.id == user.id }
    expect(user_record).to be_admin
  end

  scenario "Admin can toggle editor and reviewer bits on other users" do
    admin_page = DashboardPage.visit.visit_admin
    journal_admin_page = admin_page.visit_journal 'Journal 2'

    users = journal_admin_page.users
    user_record = users.detect { |u| u.id == user.id }
    user_record.set_editor

    admin_page = journal_admin_page.visit_admin
    journal_admin_page = admin_page.visit_journal 'Journal 1'

    users = journal_admin_page.users
    user_record = users.detect { |u| u.id == user.id }
    user_record.set_reviewer

    admin_page = journal_admin_page.visit_admin
    dashboard_page = journal_admin_page.dashboard
    admin_page = dashboard_page.visit_admin
    journal_admin_page = admin_page.visit_journal 'Journal 2'

    user_record = journal_admin_page.users.detect { |u| u.id == user.id }
    expect(user_record).to be_editor
    expect(user_record).not_to be_reviewer

    admin_page = journal_admin_page.visit_admin
    journal_admin_page = admin_page.visit_journal 'Journal 1'

    user_record = journal_admin_page.users.detect { |u| u.id == user.id }
    expect(user_record).not_to be_editor
    expect(user_record).to be_reviewer
  end
end
