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
    SignInPage.visit.sign_in admin.email
  end

  scenario "Admin can toggle the admin bit on other users" do
    admin_page = DashboardPage.visit.visit_admin
    users = admin_page.users
    expect(users.size).to eq(2)

    user_record = users.detect { |u| u.id == user.id }
    expect(user_record).to_not be_admin

    user_record.set_admin
    dashboard_page = admin_page.dashboard
    admin_page = dashboard_page.visit_admin
    user_record = admin_page.users.detect { |u| u.id == user.id }
    expect(user_record).to be_admin
  end
end
